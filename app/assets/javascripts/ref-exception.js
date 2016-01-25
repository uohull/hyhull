$(function() {
  $("#journal_article_ref_exception").change(
    function () { toggleOtherField(this); }
  );
});     

function toggleOtherField(dd) {

  var refField = $("#journal_article_ref_exception");
  var refOtherField = $("#journal_article_ref_exception_other");

  if (dd.value.toLowerCase() == "other") {
    refField.attr({ 
      name: ''
    });
    refOtherField.attr({ 
      name: 'journal_article[ref_exception]',
      type: 'text',
      value: ''
    })
    // append a temporary hidden field named 
    // [ref_exception_other], to allow passing of expected value
    refOtherField.after('<input id="tmpOtherField" type="hidden" name="journal_article[ref_exception_other]" value=""/>');
  }
  else {
    // revert the name the ref dropdown to [ref_exception]
    // revert the 'other' field to default properties and 
    // remove the temporary 'other' field
    refField.attr({ 
      name: 'journal_article[ref_exception]'
    });
    refOtherField.attr({ 
      name: 'journal_article[ref_exception_other]',
      type: 'hidden',
      value: 'false'
    });
    if ($('#tmpOtherField').length) {
      $('#tmpOtherField').remove();
    }
  }
}