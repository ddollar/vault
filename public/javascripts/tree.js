function toggle_folder(e)
{
  if (e.hasClassName('open'))
  {
    e.removeClassName('open');
    e.addClassName('closed');
    return('closed');
  }
  else
  {
    e.removeClassName('closed');
    e.addClassName('open');
    return('open');
  }
}

function folder_clicked(id, uri) 
{
  link = $('link' + id)
  
  if (toggle_folder(link) == 'closed') {
    
    rows = $$('#tree tr').each(function(e) {
      if (e.id.indexOf(id + '_') != -1) {
        e.parentNode.removeChild(e)
      }
    });
    
    update_table_stripe();
    
  } else {
    
    link.addClassName('spinner');
    
    new Ajax.Request(uri + '?parent_id=' + id, {
      method:       'get',
      asynchronous: true,
      evalScripts:  false
    });
    
  }
  
  return(false);
}

var _cycle_holder = '';

function reset_cycle()
{
  _cycle_holder = '';
}

function cycle(one, two)
{
  _cycle_holder = (_cycle_holder == one) ? two : one;
  return (_cycle_holder);
}

function update_table_stripe() 
{
  reset_cycle();
  
  rows = $$('#tree tr').each(function(e) {
    
    e.removeClassName('one');
    e.removeClassName('two');
    e.addClassName(cycle('one', 'two'));

  });
}
  
function loading_finished(id) 
{
  update_table_stripe();
  link = $('link' + id)
  
  if (link)
  {
    link.removeClassName('spinner');
    link.addClassName('open');
  }
}

function create_table_row(options)
{
  /*
  
  required options:
  
    after
    id
    depth
    uri
    text
    is_directory
    size
    revision
    date
    author
    log
    
  */
  
  tr = document.createElement('tr');
  tr.id = 'tr' + options.id;

    td = document.createElement('td');
    td.style.paddingLeft = '' + ((options.depth*16)+8) + 'px';
    tr.appendChild(td);

      link = document.createElement('a');
      link.id = 'link' + options.id;
      link.innerHTML = options.text;
      link.href = options.uri;
      
      if (options.is_directory) 
      {
        link.onclick = function(e) { return folder_clicked(options.id, options.uri); }
        link.addClassName('folder');
        link.addClassName('closed');
      }
      else
      {
        link.addClassName('file');
      }
    
      td.appendChild(link);

    td = document.createElement('td');
    td.innerHTML = options.size;
    tr.appendChild(td);

    td = document.createElement('td');
    td.innerHTML = options.revision;
    tr.appendChild(td);

    td = document.createElement('td');
    td.innerHTML = options.date;
    tr.appendChild(td);

    td = document.createElement('td');
    td.innerHTML = options.author;
    tr.appendChild(td);

    td = document.createElement('td');
    td.innerHTML = options.log;
    tr.appendChild(td);

  options.after.parentNode.insertBefore(tr, options.after.nextSibling);

  return tr;
}
