$( document ).ready(function() {  
    $("#property_name").keyup(function() {                 
        $('#property_value').val(this.value);                  
    });

    $("#property_name").blur(function() {                 
        $('#property_value').val(this.value);                  
    });
});
