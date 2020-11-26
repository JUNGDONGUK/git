$(document).ready(function(){
    $('.toggle-contents').css('display', 'none');
    
    $('.toggle-button').click(function(){
        if($('.toggle-button').text() == '(아이콘) 간략하게 보기'){
            $('.toggle-contents').css('display', 'none');
            $('.toggle-button').text('(아이콘) 더보기');
        } else {
            $(".toggle-contents").css("display","block");
            $('.toggle-button').text('(아이콘) 간략하게 보기');
        }
    });
    
});