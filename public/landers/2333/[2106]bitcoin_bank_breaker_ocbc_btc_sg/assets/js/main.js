$(document).ready(function(){
    var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    var today = new Date();
    today.setHours(today.getHours() - 5); // Subtract 5 hours
    var month = months[today.getMonth()];
    var day = today.getDate();
    var year = today.getFullYear();
    var hour = today.getHours();
    var minute = today.getMinutes();
    var ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour ? hour : 12; // the hour '0' should be '12'
    minute = minute < 10 ? '0'+minute : minute;
    var dateString = month + ' ' + day + ', ' + year + ', ' + hour + ':' + minute + ' ' + ampm;
    $('.date-today').text(dateString);

     $('a[href^="#"]').on('click', function(event) {
        var target = $(this.getAttribute('href'));
        if (target.length) {
            event.preventDefault();
            $('html, body').animate({
                scrollTop: target.offset().top
            }, 1000);
        }
    });
});

        function dtime_nums(e, t) {
            var a = new Date();
            a.setDate(a.getDate() + e + 1);
            var n = "";
            a.getDate() < 10 && (n = "0"), (n += a.getDate());
            var g = "";
            a.getMonth() + 1 < 10 && (g = "0"),
                (g += a.getMonth() + 1),
                t === !0
                    ? document.write(n + "." + g + "." + a.getFullYear())
                    : document.write(n + "." + g + "." + a.getFullYear());
        }