// smooth scroll
$(function () {
  $('a[href^=#]').on("click", function () {
    var speed = 400,
      href = $(this).attr("href"),
      target = $(href === "#" || href === "" ? 'html' : href),
      position = target.offset().top;
    $("html, body").animate({scrollTop: position}, speed, "swing");
    return false;
  });
  // hamburger menu
  $(".js-hamburger").on("click", function () {
    $(".js-nav").slideToggle(function () {
      $(".js-hamburger").hide();
      $(".js-close").show();
    });
  });
  $(".js-close").on("click", function () {
    $(".js-nav").slideToggle(function () {
      $(".js-close").hide();
      $(".js-hamburger").show();
    });
  });
});
