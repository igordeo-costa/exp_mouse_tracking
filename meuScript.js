PennController.ResetPrefix(null)

Sequence("meuexemplo", randomize("minhasfrases"))

newTrial("meuexemplo",
    defaultText
        .center()
        .print()
    ,

    newText("Para começar o experimento, após esta tela, aperte o botão INICIAR.A seguir serão apresentadas duas imagens. Observe-as com atenção. Alguns segundos depois, entre as imagens, aparecerão rapidamente algumas palavras, formando uma frase.<br><br> Enquanto lê a frase, clique o mais rápido possível na imagem compatível com a frase. Clique assim que tiver certeza sobre qual é a imagem referida pela frase. Você não precisa esperar a frase terminar para clicar.<br><br> Tente <b>não mover o mouse</b> após clicar no botão iniciar, deixando para movê-lo apenas quando decidir clicar na opção escolhida.")
    ,

    newText("<br>Vamos começar?<br><br>")
    ,

    newButton("meubotao", "Sim!")
        .center()
        .print()
        .wait()
)
,

Template("frases.csv",
    exp => newTrial("minhasfrases",
    newImage("a1", "aviso1.png")
        .size(200,200)
    ,

    newImage("a2", "aviso3.png")
        .size(200,200)
    ,
    
    /*
    // Investigar a aplicação desse aviso com mais atenção! 
    newTooltip("earlyWarning", "STARTED TOO EARLY. You moved your mouse from the Go button before it was possible to guess the correct option. Please don't move your mouse until you're about to click.")
    ,
    
    newVar("isEarly", false).global()
    ,
    
    newTimer("earlyStart", (2000))
        .start()
    ,
    */
    
    newMouseTracker("mouse")
        .log()
        //.callback( getTimer("earlyStart").test.running().success(getVar("isEarly").set(true)) )
        .start()
    ,

    newButton("botao_inic", "INICIAR")
        .print("center at 50%" , "bottom at 90%")
        .wait()
        .remove()
    ,

    newCanvas("canvas_esq", 1100, 500)
        .add(0, 0, getImage("a1"))
        .print("center at 50vw", "top at 6em")
    ,

    newCanvas("canvas_dir", 1100, 500)
        .add(900, 0, getImage("a2"))
        .print("center at 50vw", "top at 6em")
    ,

    newTimer("pausa", 2000)
    .start()
    .wait()
    ,

    newController("DashedSentence",
        {s: exp.frase, mode: "speeded acceptability", display: "in place", wordTime: 400})
            .css({"font-size": "18px"})
            .center()
            .print()
            .log()
    ,
    
    getMouseTracker("mouse")
        .stop()
    ,
    newSelector("escolha")
        .add(getCanvas("canvas_esq"), getCanvas("canvas_dir"))
        .wait()
        .log()
    )
    .log("grupo", exp.group)
    .log("item", exp.item)
    .log("frases", exp.frase)
    )
