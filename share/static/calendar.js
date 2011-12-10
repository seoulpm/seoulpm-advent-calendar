$(window).load(function(){
    window.setInterval(function(){
        $("#ball-today").toggleClass("today");
    }, 900);
    $(".ball").hover(function(en){
        $(this).addClass("today");
    }, function(){
        $(this).removeClass("today");
    });
});