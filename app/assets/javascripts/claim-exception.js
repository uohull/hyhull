$(function() {
  $("#ClaimExceptionSel").change(
    function () { toggleClaimField(this); }
  );
});     

function toggleClaimField(dd) {
  var clExSel = $("#ClaimExceptionSel");
  var clExControl = $("#ClaimExceptionControl");
  var clExField = $("#journal_article_depositor_note");

  if ( (dd.value.toLowerCase() == 'yes') && (clExControl.is(":hidden")) ) {
    clExControl.fadeIn('500');
  } 
  if ( (dd.value.toLowerCase() == 'no') && (clExControl.is(":visible")) ) {
    clExControl.fadeOut('500');
     clExField.val("");
  }
}

(function() {
  if ($("#journal_article_depositor_note").length) {
    // hide field if blank and set control (on document ready). As 
    // value for 'Claim exception' is not being stored, this is the
    // only way to tell if the field needs to be shown or not
    if ($("#journal_article_depositor_note").val().trim().length < 1) {
      $("#ClaimExceptionControl").hide();
      $("#ClaimExceptionSel").val("No");
    }
    else {
      $("#ClaimExceptionControl").show();
      $("#ClaimExceptionSel").val("Yes");
    }
  }
})();
