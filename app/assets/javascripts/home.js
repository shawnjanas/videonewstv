$(document).ready(function() {
  if($('#user-init').length != 0) {
    var interval = setInterval(function() {
      $.getJSON('/user_ready', function(data) {
        if(data.ready) {
          clearInterval(interval);
          location.reload();
        }
      });
    }, 2000);
  }

  $('.video-entry').live('click', function() {
    var video_id = $(this).attr('video-id');

    $('#video-player').html('<object width="380" height="214"><param name="movie" value="http://www.youtube.com/v/'+video_id+'?hl=en_GB&amp;version=3&autoplay=1&amp;rel=0"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/'+video_id+'?hl=en_GB&amp;version=3&autoplay=1&amp;rel=0" type="application/x-shockwave-flash" width="380" height="214" allowscriptaccess="always" allowfullscreen="true"></embed></object>');

    $(this).parent().find('.selected').removeClass('selected');
    $(this).addClass('selected');
  });

  var loading = false;
  var page = 2;

  setInterval(function(){
    var totalHeight, currentScroll, visibleHeight;

    if (document.documentElement.scrollTop) {
      currentScroll = document.documentElement.scrollTop;
    } else {
      currentScroll = document.body.scrollTop;
    }

    totalHeight = document.body.offsetHeight;
    visibleHeight = document.documentElement.clientHeight;

    if (totalHeight-10 <= currentScroll + visibleHeight ) {
      if(!loading) {
        load_more_videos();
      }
    }
  }, 100);

  function load_more_videos() {
    loading = true;

    $.ajax('/more_videos/'+page, {
      dataType: 'html'
    }).done(function (html) {
      $('.video-entry-container').append(html);
      if(html !== "There were no videos found\n") {
        page++;
        loading = false;
      }
    });
  }
})
