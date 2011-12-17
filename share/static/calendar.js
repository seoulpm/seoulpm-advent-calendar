var adventcalendar = {
    profile: [];
};
$(window).load(function(){
    window.setInterval(function(){
        $("#ball-today").toggleClass("today");
    }, 900);
    $(".ball").hover(function(){
        var offset = $(this).offset();
        var tooltip = $("#tooltip");
        var author = $(".author", $(this).parent()).text();
        var title = $(".title", $(this).parent()).text();
        $(this).addClass("bling");
        tooltip.css("left", offset.left - 280 + 50 + 9);
        tooltip.css("top", offset.top - 86 - 15);
        tooltip.css("display", "block");
        $("#tooltip .author").text(author);
        $("#tooltip .title").text(title);
        $("#tooltip .image").attr("src", "profile_" + author + ".jpg");
    }, function(){
        $(this).removeClass("bling");
        $("#tooltip").css("display", "none");
    });
});
