/*
 *  CoolTipBox Plugin for JQuery
 *  Examples and documentation at: http://plugins.jquery.com/project/cooltipbox
 *
 *  Copyright 2010, Bruno Bruck
 *  Released under the MIT license (http://www.opensource.org/licenses/mit-license.php)
 *
 *  Version 1.1.7 (03-NOV-2010)
 *
 *  Author website: http://www.visusgroup.com.br
 */

(function($) {

    

    $.fn.cooltipbox = function(text, settings) {

        settings = $.extend({}, $.fn.cooltipbox.defaults, settings);

        this.each(function() {

            var $this = $(this)
                ,$content = $('<div class="cool-tip-box-content">' + text + '</div>')
                ,$wrapper = $content.wrap('<div class="cool-tip-box">').parent()
                ,$arrow = '';

            $('body').append($wrapper);

            var width = settings.width  + 'px'
                ,height = settings.height + 'px'
                ,fontSize = settings.fontSize + 'pt';

            //===============================================
            //== Apply some settings
            //===============================================

            if(settings.width != 'auto') width += 'px';
            if(settings.height != 'auto') height += 'px';
            if(settings.id != '') $wrapper.attr('id', settings.id);
            $content.css('font-family', settings.fontFamily);
            $content.css('font-size', fontSize);
            $content.css('color', settings.textColor);
            $content.css('background', settings.background);
            $content.width(width);
            $content.height(height);
            $content.css('padding', settings.contentPadding);
            $content.css('cursor', settings.cursor);


            //===============================================
            //== Create arrow container
            //===============================================
            if(settings.withArrow && !settings.followMouse){
                switch(settings.position){
                    case 'top':
                        $arrow = $('<div class="cool-tip-box-v-arrow"></div>');
                        $content.after($arrow);
                        break;
                    case 'bottom':
                        $arrow = $('<div class="cool-tip-box-v-arrow"></div>');
                        $content.before($arrow);
                        break;
                    case 'left':
                        $arrow = $('<div class="cool-tip-box-h-arrow"></div>');
                        $content.after($arrow);
                        break;
                    case 'right':
                        $arrow = $('<div class="cool-tip-box-h-arrow"></div>');
                        $content.before($arrow);
                        break;
                }
            }


            //===============================================
            //== Append Arrow
            //===============================================
            switch(settings.position){
                case 'top':
                    if(settings.withArrow && !settings.followMouse)
                        appendArrowT1($arrow);
                    break;

                case 'bottom':
                    if(settings.withArrow && !settings.followMouse)
                        appendArrowT2($arrow);
                    break;

                case 'left':
                    if(settings.withArrow && !settings.followMouse)
                        appendArrowT1($arrow);
                    break;

                case 'right':
                    if(settings.withArrow && !settings.followMouse)
                        appendArrowT2($arrow);
                    break;
            }

            //===============================================
            //== Position the tipbox
            //===============================================
            positionTipBox($this, $arrow, $content, $wrapper, settings);

            //===============================================
            //== Apply shadow settings
            //===============================================
                if(settings.shadowed){
                    $content.css({
                        'box-shadow': '0 0 6px ' + settings.shadowColor
                        ,'-moz-box-shadow': '0 0 6px ' + settings.shadowColor
                        ,'-webkit-box-shadow': '0 0 6px ' + settings.shadowColor
                    });

                    if(settings.withArrow && !settings.followMouse){
                        var shadowValueH = '2px'
                            ,shadowValueV = '0px';

                        switch(settings.position){
                            case 'bottom':shadowValueV = '-2px';break;
                            case 'left':shadowValueV = '0';shadowValueH = '2px';break;
                            case 'right':shadowValueV = '0';shadowValueH = '-2px';break;
                        }

                        $arrow.children().css({
                            'box-shadow': shadowValueH + ' ' + shadowValueV + ' 2px ' + settings.shadowColor
                            ,'-moz-box-shadow': shadowValueH + ' ' + shadowValueV + ' 4px ' + settings.shadowColor
                            ,'-webkit-box-shadow': shadowValueH + ' ' + shadowValueV + ' 4px ' + settings.shadowColor
                        });
                    }
                }

            //===============================================
            //== Border setting
            //===============================================
            if(settings.bordered) $content.css('border', '2px ' + settings.borderType + ' ' + settings.borderColor);

            //===============================================
            //== Rounded corner
            //===============================================
            if(settings.rounded){
                settings.radius += 'px';
                $content.css({
                    'border-radius': settings.radius
                    ,'-moz-border-radius': settings.radius
                    ,'-webkit-border-radius': settings.radius
                });
            }

            //===============================================
            //== Visisble setting
            //===============================================
            if(settings.visible) $wrapper.show();
            else $wrapper.hide();


            //===============================================
            //== Bind events
            //===============================================

            switch(settings.hideOnTrigger){
                case 'this':
                    $this.bind(settings.hideOn, function(e){
                        $wrapper.children().fadeOut(settings.fadeOut);
                    });

                    break;
                case 'tipbox':
                    $content.bind(settings.hideOn, function(){
                        $wrapper.children().fadeOut(settings.fadeOut);
                    });
                    break;
                default:
                    $(settings.hideOnTrigger).bind(settings.hideOn, function(){
                        $wrapper.children().fadeOut(settings.fadeOut);
                    });


            }

            switch(settings.showOnTrigger){
                case 'this':
                    $this.bind(settings.showOn, function(e){
                        e.stopPropagation();
                        if($wrapper.css('display') == 'none' || $content.css('display') == 'none'){
                            $wrapper.fadeIn(settings.fadeIn);
                            $wrapper.children().fadeIn(settings.fadeIn);
                        }
                    });
                    break;
                default:
                    $(settings.showOnTrigger).bind(settings.showOn, function(){
                        if($wrapper.css('display') == 'none' || $content.css('display') == 'none'){
                            $wrapper.fadeIn(settings.fadeIn);
                            $wrapper.children().fadeIn(settings.fadeIn);
                        }
                    });
            }

            if(settings.followMouse && $content.css('display') != 'none'){
                $this.bind('mousemove', function(e){
                    $wrapper.css({"display":"block", "top":e.pageY+16, "left":e.pageX});
                });
            }

            $(window).bind('resize', function(){
                positionTipBox($this, $arrow, $content, $wrapper, settings);
            });

        });

        return this;
    };

    function appendArrowT1($arrow){
        $arrow.append("<div class='part1'></div> ");
        $arrow.append("<div class='part2'></div> ");
        $arrow.append("<div class='part3'></div> ");
        $arrow.append("<div class='part4'></div> ");
        $arrow.append("<div class='part5'></div> ");
        $arrow.append("<div class='part6'></div> ");
        $arrow.append("<div class='part7'></div> ");
        $arrow.append("<div class='part8'></div> ");
    }

    function appendArrowT2($arrow){
        $arrow.append("<div class='part8'></div> ");
        $arrow.append("<div class='part7'></div> ");
        $arrow.append("<div class='part6'></div> ");
        $arrow.append("<div class='part5'></div> ");
        $arrow.append("<div class='part4'></div> ");
        $arrow.append("<div class='part3'></div> ");
        $arrow.append("<div class='part2'></div> ");
        $arrow.append("<div class='part1'></div> ");
    }

    function positionTipBox($this, $arrow, $content, $wrapper, settings){

        var arrowMarginValue = ''
            ,offSetTop = 0
            ,offSetLeft = 0;

        switch(settings.position){
            case 'top':
                if(settings.withArrow && !settings.followMouse){
                    arrowMarginValue = parseInt($content.outerHeight());
                    $arrow.css('margin-top', arrowMarginValue + 'px');
                }

                if(settings.bordered) arrowMarginValue += 2;

                //===============================================
                //== Position the box according to the settings
                //== 'position' and 'positionOffSet'
                //===============================================
                    offSetTop = $this.offset().top - $content.outerHeight() - 15;
                    offSetLeft = $this.offset().left + settings.positionOffSet;
                    $wrapper.css({'top' : offSetTop + 'px', 'left' : offSetLeft + 'px'});


                break;

            case 'bottom':
                if(settings.withArrow && !settings.followMouse)
                    $arrow.css('margin-top', '-6px');

                //===============================================
                //== Position the box according to the settings
                //== 'position' and 'positionOffSet'
                //===============================================
                    offSetTop = $this.offset().top + $this.outerHeight() + 12   ;
                    offSetLeft = $this.offset().left + settings.positionOffSet;
                    $wrapper.css({'top' : offSetTop + 'px', 'left' : offSetLeft + 'px'});

                break;

            case 'left':
                if(settings.withArrow && !settings.followMouse){
                    arrowMarginValue = parseInt($content.outerWidth());
                    $arrow.css('margin-left', arrowMarginValue + 'px');
                }

                if(settings.bordered) arrowMarginValue += 2;

                //===============================================
                //== Position the box according to the settings
                //== 'position' and 'positionOffSet'
                //===============================================
                    offSetTop = $this.offset().top - 10 + settings.positionOffSet;
                    offSetLeft = $this.offset().left - $content.outerWidth() - 15;
                    $wrapper.css({'top' : offSetTop + 'px', 'left' : offSetLeft + 'px'});

                break;

            case 'right':
                if(settings.withArrow && !settings.followMouse)
                    $arrow.css('margin-left', '-6px');

                //===============================================
                //== Position the box according to the settings
                //== 'position' and 'positionOffSet'
                //===============================================
                    offSetTop = $this.offset().top - 10 + settings.positionOffSet;
                    offSetLeft = $this.offset().left + $this.outerWidth() + 15;
                    $wrapper.css({'top' : offSetTop + 'px', 'left' : offSetLeft + 'px'});

                break;
        }

        //===============================================
        //== Position the arrow according to the setting
        //== arrowPosition
        //===============================================
        if(settings.withArrow && !settings.followMouse){
            switch(settings.position){
                case 'top':
                case 'bottom':
                    var auxW = parseInt($content.width());
                    if(settings.arrowPosition >= (settings.radius + 4) && (auxW - (settings.radius + 4) ) >= settings.arrowPosition){
                        settings.arrowPosition += 'px';
                        $arrow.css('margin-left', settings.arrowPosition);
                    }
                    else $arrow.css('margin-left', settings.radius + 4);
                    break;

                case 'left':
                case 'right':
                    var auxH = parseInt($content.height());
                    if(settings.arrowPosition >= (settings.radius + 4) && (auxH - (settings.radius + 4) ) >= settings.arrowPosition){
                        settings.arrowPosition += 'px';
                        $arrow.css('margin-top', settings.arrowPosition);
                    }
                    else $arrow.children().css('margin-top', settings.radius + 4);
                    break;
            }

            $arrow.children().css('background-color', settings.bgColor);
        }
    }

})(jQuery);

$.fn.cooltipbox.defaults = {
    bordered: false,
    borderColor: '#ddd',
    borderType: 'solid',
    radius: 8,
    rounded: true,
    cursor: 'auto', // Any valid value of the CSS property cursor
    fontFamily: 'Helvetica, Arial, sans-serif',
    fontSize: '8.5', //Unit: pt
    background: '#393939',
    textColor: '#fff',
    withArrow: true,
    arrowPosition: 15, //Unit: px, min: (radius + 4), max: (width - (radius+4))
    height: 'auto',
    width: 150,
    shadowed: true,
    shadowColor: '#000',
    contentPadding: '10px',
    visible: false,
    position: 'top', //Can be 'top', 'right', 'bottom' or 'left'
    positionOffSet: 0,
    id : '',
    fadeIn: '1000',
    fadeOut: '1000',
    showOnTrigger: 'this',
    showOn: 'mouseover',
    hideOnTrigger: 'this',
    hideOn: 'mouseleave',
    followMouse: false
};
