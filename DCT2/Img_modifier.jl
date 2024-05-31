using FFTW
using FileIO
using Images

using Gtk

function import_bmp(path)
    abs_path = abspath(path) 
    img = load(File{format"BMP"}(abs_path))
    #export_bmp(img, "./img/generate1.bmp")
    return Float32.(Gray.(img)) * 255
end

function export_bmp(img, path)
    abs_path = abspath(path)
    FileIO.save(File(format"BMP", abs_path), img/255)
end

function preprocessing_img(img, F)
    img = crop_image(img, F)
    blocks = build_blocks(img, F)
    return blocks
end

function crop_image(img, F)
    return img[1:size(img)[1]-(size(img)[1]%F), 1:size(img)[2]-(size(img)[2]%F)]
    #println(img[1:size(img)[1]-(size(img)[1]%F), 1:size(img)[2]-(size(img)[2]%F)])
end

function build_blocks(img, F)
    dim = size(img)
    blocks = [img[i:min(i+F-1,dim[1]), j:min(j+F-1,dim[2])] for i in 1:F:dim[1], j in 1:F:dim[2]]
    return blocks
end

function delete_frequencies(block, d)
    for i = 1:size(block)[1]
        for j = 1:size(block)[2]
            if i + j - 2 > d
                block[i,j] = 0
            end
        end
    end
    return block
end

function normalize(block)
    block = round.(Int, block) # Arrotonda all'intero più vicino
    block = max.(0, block) # Mette a zero i valori negativi
    block = min.(255, block) # Limita i valori a 255
    return block
end

function modify_img(path, F, d)
    img = import_bmp(path)
    blocks = preprocessing_img(img, F)
    
    for i in 1:size(blocks)[1]
        for j in 1:size(blocks)[2]
            block = blocks[i,j]
            block = FFTW.dct(block)
            block = delete_frequencies(block, d)
            block = FFTW.idct(block)
            block = normalize(block)
            blocks[i,j] = block
        end
    end

    export_bmp(reduce(vcat, [reduce(hcat, blocks[i, :]) for i in 1:size(blocks)[1]]), "./img/modified3final.bmp")

end


#import_bmp("./img/prova1.bmp")
#modify_img("./img/sample3.bmp", 8, 10)

function create_gui()
    win = Gtk.Window("Hello, GUI!", 1000, 500) # Crea una finestra

    button = Gtk.Button("Scegli un file") # Crea un pulsante
    signal_connect(button, "clicked") do widget # Aggiunge un gestore di eventi al pulsante
        dialog = Gtk.FileChooserDialog("Scegli un file", win, Gtk.GtkFileChooserAction.OPEN, 
                                        (("Annulla", Gtk.GtkResponseType.CANCEL), 
                                         ("Apri", Gtk.GtkResponseType.ACCEPT)))
        response = run(dialog)
        if response == Gtk.GtkResponseType.ACCEPT
            val = Gtk.GAccessor.filename(Gtk.GtkFileChooser(dialog))
            if val != C_NULL
                filename = Gtk.bytestring(val)
                println("Filename: ", filename)
                task = @async modify_img(filename, 8, 10) # Crea un task asincrono
                wait(task) # Aspetta che il task sia completato
            
                # Crea un dialogo di input personalizzato per ottenere F e d dall'utente
                input_dialog = MessageDialog(win, QUESTION, OK_CANCEL, "Inserisci F e d")
                vbox = Gtk.dialog_get_content_area(input_dialog)
                F_entry = Gtk.Entry()
                d_entry = Gtk.Entry()
                push!(vbox, Gtk.Label("Inserisci il valore di F:"))
                push!(vbox, F_entry)
                push!(vbox, Gtk.Label("Inserisci il valore di d:"))
                push!(vbox, d_entry)
                showall(input_dialog)
                response = run(input_dialog)
                if response == Gtk.ResponseType.OK
                    F = parse(Float64, Gtk.Entry.get_text(F_entry))
                    d = parse(Float64, Gtk.Entry.get_text(d_entry))
                    println(F)
                    println(d)
                end
                destroy(input_dialog)
                destroy(win)
            end
            destroy(dialog)
        end
        destroy(dialog)
    end

    push!(win, button) # Aggiunge il pulsante alla finestra

    showall(win) # Mostra la finestra
end

@async create_gui()
Gtk.gtk_main()


