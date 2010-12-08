
function getModuleList(target) {

  $.post('/data/modules', { 'type': 'list' }, function(data) {
    var frag = document.createDocumentFragment();
    if ( data.status == 'success') {
      $.each(data.content, function(i,item) {
        var e = document.createElement('div');
        e.setAttribute('class', 'item');
        $(e).bind('click', function(evt) {
          getModule(evt.target.innerHTML, ['#description','#status','#editor'] );
        });
        e.innerHTML = item;
        frag.appendChild(e);
      });
      $(target)[0].appendChild(frag);
    } else {
      $(target).appendChild('<div>Request '+data.status+':</div<pre>'+data.message+'</pre>');
    }
  }, "json");
};

function getModule(module,targets) {

  $.post('/data/modules', { 'type': 'content', 'module': module }, function(data) {
    if ( data.status == 'success') {
      $(targets[0]).html(data.content.description);
      $(targets[1]).html(data.content.state);
      $(targets[2]).html(data.content.body);
      $(targets[2]).show();
    } else {
      $(target).appendChild('<div>Request '+data.status+': '+data.message+'</div>');
    }
  }, "json");
};

function getConfiguration(target) {

  $.post('/data/configuration', { 'type': 'list' }, function(data) {
    var frag = document.createDocumentFragment();
    if ( data.status == 'success') {
      $.each(data.content, function(i,item) {
        var e = document.createElement('tr');
        var k = document.createElement('td');
        var v = document.createElement('td');
        k.innerHTML = i;
        k.setAttribute('class', 'key');
        v.innerHTML = item
        v.setAttribute('class', 'value');
        $(v).editable('text');
        e.appendChild(k);
        e.appendChild(v);
        frag.appendChild(e);
      });
      $(target)[0].appendChild(frag);
    } else {
      // todo: should wipe target first!
      $(target).append('<tr><td>equest '+data.status+': '+data.message+'</td></tr>');
    }
  }, "json");
};

function addConfigurationField(target) {
  var e = document.createElement('tr');
  var k = document.createElement('td');
  var v = document.createElement('td');
  k.innerHTML = 'Setting Name';
  k.setAttribute('class', 'key');
  v.innerHTML = 'Setting Value'
  v.setAttribute('class', 'value');
  $(k).editable('text');
  $(v).editable('text');
  e.appendChild(k);
  e.appendChild(v);
  $(target).append(e);
}

function getStatus(target) {

  $.post('/data/status', { 'type': 'list' }, function(data) {
    var frag = document.createDocumentFragment();
    if ( data.status == 'success') {
      var e,k,v;

      if ( data.content.connected != null ) {
        e = document.createElement('div');
        k = document.createElement('span');
        v = document.createElement('span');

        k.innerHTML = "connected";
        k.setAttribute('class', 'key');
        v.innerHTML = data.content.connected;
        v.setAttribute('class', 'value');

        e.appendChild(k);
        e.appendChild(v);
        frag.appendChild(e);
      }
      if (data.content.rooms != null ) {
        e = document.createElement('div');
        k = document.createElement('span');

        k.innerHTML = "rooms";
        k.setAttribute('class', 'key');
        var l = document.createElement('ul');
        $.each(data.content.rooms, function(j,entry) {
          l.appendChild("<li>"+entry+"</li>");
        });
        e.appendChild(k);
        e.appendChild(l);
        frag.appendChild(e);
      }

      $(target)[0].appendChild(frag);
    } else {
      $(target)[0].appendChild('<div>Request '+data.status+': '+data.message+'</div>');
    }
  }, "json");
};

function getRoomList(target,type) {
  if (!type) {
    var type = 'li';
  }

  $.post('/data/configuration', { 'type': 'list' }, function(data) {
    var frag = document.createDocumentFragment();
    if ( data.status == 'success') {
      if (data.content.rooms != null ) {
        $.each(data.content.rooms, function(j,entry) {
          var e = document.createElement(type);
          $(e).text(entry);
          frag.appendChild(e);
        });

        $(target)[0].appendChild(frag);
      }
    } else {
      $(target)[0].appendChild('<div>Request '+data.status+': '+data.message+'</div>');
    }
  }, "json");
};
