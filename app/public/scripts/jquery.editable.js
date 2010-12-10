(function( $ ){

  $.fn.editable = function(type) {
    return this.each( function() {
      $this = $(this);

      $this.bind('click.editable', function(){ edit(this,type) } );
      $this.bind('mouseover.editable', function(){ showAsEditable(this) });
      $this.bind('mouseout.editable', function(){ showAsEditable(this, true) });
    });
  }

  function showAsEditable(obj, clear){
    if (!clear){
      $(obj).addClass('editable');
    }else{
      $(obj).removeClass('editable');
    }
  }

  function edit(obj,type){
    $(obj).hide();

    var field;
    if ( type == "text") {
      field = document.createElement('input');
      field.type = 'text';
    } else if ( type == "textarea" ) {
      field = document.createElement(type);
    }

    $(field).attr("id", $(obj).attr("id") + '_editor');
    $(field).val($(obj).html());

    $(obj).after($(field));

    $(field).bind('keydown.editable', function(event){
      if (event.which == 27) cleanUp(obj, true);
    });
    $(field).blur(function(){
      applyChanges(obj);
    });

    $(field).focus();
  }

  function cleanUp(obj, keepEditable){
    $('#'+$(obj).attr("id")+'_editor').remove();
    $(obj).show();
    if (!keepEditable) showAsEditable(obj, true);
  }

  function applyChanges(obj){
    $(obj).html($('#'+$(obj).attr("id")+'_editor').val());
    cleanUp(obj, true);
  }
})( jQuery );

