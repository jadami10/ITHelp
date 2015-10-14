import 'normalize-css';

import '../styles/solve.styl';

$(() => {
  
  $('.prob').click((e) => {
    const $t = $(e.target).closest($('.prob'));
    $t.find($('.desc')).toggle('fast');
    $t.find($('.btn-help')).toggle('fast');
  });

});
