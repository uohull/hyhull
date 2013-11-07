$(function() {
  $( ".datepicker" ).datepicker({ 
    dateFormat: "yy-mm-dd"
  });
});

/* 
 * This method is used to change the colour of the Metadata tab pane links if validation errors are present in the form
 * Class 'error-link' is adding to the a-link and required * symbol is prepended.
 * metadata-edit-nav id is required on the nav tab-pane
 */
$( document ).ready(function() {
  $('#metadata-edit-nav > li').each( function() {
    var tab_pane_id = $(this).children().attr('href');     
    var error_fields =  $(tab_pane_id).find('.error');

    if (error_fields.size() > 0) {
      var a_element = $(this).children('a')
      // Add the error-link class and * abbrievation
      $(a_element).addClass('error-link')
      $(a_element).prepend('<abbr title="required">*</abbr>&nbsp;')
    }
  });
});
