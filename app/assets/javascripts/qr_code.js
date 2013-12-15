/*
 * QR Code. This Javascript will load the QR image tag (google chart api) into the qr-code div when a user clicks on the 'QR Code' link on the record view page
 * The markup for the QR Code is stored at app/views/catalog/_qr_code.html.erb and is rendered from _show_tools.html.erb
 */  
$(document).ready(function() {
    create_qr_image_tag($(this));
});

function create_qr_image_tag(scope) {
  // Populates the qr div element on click of the qr button
  scope.find('#qr-link').click(function(){
    // Gets the full href
    var pathname = window.location.href;
    // Empties the current qr-code div, and then re-populates it with the new image tag
    $('#qr-code').empty();
    $('#qr-code').prepend('<img id="qr-image" src="https://chart.googleapis.com/chart?cht=qr&chl=' + pathname + '&chs=240x240" alt="QR Code" title="QR Code"/>')
  });
}