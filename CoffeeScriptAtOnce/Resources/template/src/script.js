// CS,jQ
$ ->
  $('#btn').on 'click', ->
    alert $('#txt').val()

// CS
document.querySelector('#btn')
.addEventListener 'click', ->
  alert document.querySelector('#txt').value
, false

// jQ
$(function() {
  $('#btn').on('click', function() {
    alert($('#txt').val());
  });
});

// JS
window.addEventListener('load', function() {
  document.querySelector('#btn')
  .addEventListener('click', function() {
    alert(document.querySelector('#txt').value);
  }, false);
}, false);
// csatonce
