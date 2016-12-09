
//リンクのスムーズスクロール

    $(function () {
    var headerHight = 0; 
    $('a.smooth[href^=#]').click(function(){
        var href= $(this).attr("href");
        var target = $(href == "#" || href == "" ? 'html' : href);
        var position = target.offset().top-headerHight; 
        $("html, body").animate({scrollTop:position}, 700, "easeInOutCubic");
        return false;
    });
});


//募集　ロールオーバー
     $('article div').hover(function(){
        $(this).css('background-color','#fff');
    }, 
    function (){
        $(this).css("background-color", "");
    });