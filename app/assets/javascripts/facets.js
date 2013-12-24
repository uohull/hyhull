/*
 * Facets display code
 * The following function is used to hide the sidebar div (contains the facets) when there are no facets to display. 
 * The code will expand the main 'content' div to the full width of the container (span 16) to utilise the extra space.
 */
$( document ).ready(function() {
  if ($("#sidebar").children(".page-gutter").length > 0) {
    //Sidebar is on the page...    
    if ($("#sidebar").children(".page-gutter").html().trim() == "") {
      //The side bar is empty, therefore we are going to add the hide class to it..
      $("#sidebar").addClass("hide");
      //... and reset the main content to span16
      $('#content').addClass("span16").removeClass("span12");
    }
  }  
});