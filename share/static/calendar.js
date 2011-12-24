var calendar = { r1: 1, r2: 10, r3: 9 };
$(window).load(function(){
    window.setInterval(function(){
        var i;
        var r1 = calendar.r1;
        var r2 = calendar.r2;
        var r3 = calendar.r3;
        r1 += 4; r1 = r1 % 25;
        r2 -= 5; r2 = r2 % 25;
        r3 += 6; r3 = r3 % 25;
        $(".ball").removeClass("today");
        $("#ball-" + r1).addClass("today");
        $("#ball-" + r2).addClass("today");
        $("#ball-" + r3).addClass("today");
        calendar.r1 = r1;
        calendar.r2 = r2;
        calendar.r3 = r3;
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
    snowStorm.randomizeWind();
    snowStorm.zIndex = 5;
    snowStorm.followMouse = false;
    snowStorm.start();
});
