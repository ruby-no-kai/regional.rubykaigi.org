$(function(){
  $('.overlayMenuBtn').on('click', function(){

    var $overlay = $('.overlayMenu');
    var openClass = 'open';

    if( !$overlay.hasClass(openClass) ){

      $('.overlayMenuBtn span:nth-child(1)').css({'transform':'rotate(-45deg)', 'top':'10px'});
      $('.overlayMenuBtn span:nth-child(2)').css({'opacity':'0'});
      $('.overlayMenuBtn span:nth-child(3)').css({'transform':'rotate(45deg)', 'top':'9px', 'border-top': '1px solid #fff'});

      $overlay.addClass(openClass);
      $('body').css( 'height', '100vh');
      $overlay.fadeIn('fast');

    } else {

      $('.overlayMenuBtn span:nth-child(1)').css({'transform':'rotate(0)', 'top':'0px'});
      $('.overlayMenuBtn span:nth-child(2)').css({'opacity':'1'});
      $('.overlayMenuBtn span:nth-child(3)').css({'transform':'rotate(0)', 'top':'20px', 'border-top': '1px solid #fff'});

      $overlay.removeClass(openClass);
      $overlay.fadeOut('fast');
    }

  });
});