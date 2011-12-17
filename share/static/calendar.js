$(window).load(function(){
    window.setInterval(function(){
        $("#ball-today").toggleClass("today");
    }, 900);
    $(".ball").hover(function(){
        var offset = $(this).offset();
        var tooltip = $("#tooltip");
        $(this).addClass("bling");
        tooltip.css("left", offset.left - 280 + 50 + 9);
        tooltip.css("top", offset.top - 86 - 15);
        tooltip.css("display", "block");
        $("#tooltip .author").text($(".author", $(this).parent()).text());
        $("#tooltip .title").text($(".title", $(this).parent()).text());
    }, function(){
        $(this).removeClass("bling");
        $("#tooltip").css("display", "none");
    });
});
