"use strict";

$(document).on('click', '.flip', function () {
  let card = $(this).closest('.card');
  if (card.hasClass('flip-it')) card.removeClass('flip-it');else card.addClass('flip-it');
});
$('.card').each(function () {
  let href = $(this).data('href');
  $(this).find('.image').css({
    backgroundImage: ['url(', href, ')'].join('')
  });
});
