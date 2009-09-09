/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
function searchFormTabs(arr0){
  var arr=arr0
  var tabs_relative=$('<div id="search_form_tabs_relative">').html('&nbsp;')
  var tabs_holder=$('<div id="search_form_tabs"></div>')
  var tabs=$([])
  var last_form=$([])
  for(var i=0;i<arr.length;i++){
    var form=$('#'+arr[i].id)
    if(form.length<1){
      alert('cannot find form '+arr[i].id)
    }
    if(i==0){
      tabs_relative.insertBefore(form)
      tabs_holder.appendTo(tabs_relative)
      last_form=last_form.add(form)
    }
    else{
      form.hide()
    }

    var tab=$('<a></a>').attr('href','#').data('form',form).html(arr[i].text).click(function(e){
      e.preventDefault()

      last_tab.removeClass('selected')
      last_form.hide()

      $(this).data('form').show()
      $(this).addClass('selected')

      last_tab=$(this)
      last_form=$(this).data('form')
      $.cookie('search_form',tabs.index(this),{path:'/'})

    }).appendTo(tabs_holder)

    if(i==0){
      tab.addClass('selected')
      last_tab=tab
    }
    tabs=tabs.add(tab)
  }
  if($.cookie('search_form')){
    tabs.eq($.cookie('search_form')).triggerHandler('click')
  }

}

function updateModel2(json0){
  if(!typeof(json0) == 'object'){
    alert('updatemodel2 - 1st argument must a json object')
    return 0
  }
  if(!typeof(json0.form) == 'string'){
    alert('updatemodel2 - json object must have "form"')
    return 0
  }
  if(!typeof(json0.model) == 'string'){
    alert('updatemodel2 - json object must have "model"')
    return 0
  }
  if(!typeof(json0.brand) == 'string'){
    alert('updatemodel2 - json object must have "brand"')
    return 0
  }

  var form=$(json0.form)
  if(!form.length){
    alert('updatemodel2 - '+json0.form+' not found')
    return 0
  }

  var model_select=form.find(json0.model)
  if(model_select.length<1){
    alert('updatemodel2 - '+json0.model+' not found')
    return 0
  }

  var model_options=model_select.find('option[name]')
  if(!model_options.length){
     //if no options with attribute 'name'
     alert('updatemodel2 - options must have name attributes to represent foreign key value in '+json0.model)
     return 0
  }
  var brand_select=form.find(json0.brand)
  if(brand_select.length<1){
     alert('updatemodel2 - cannot find brand '+json0.brand)
     return 0
  }

  /*
   *  Removed ability to HIDE options, because in firefox, u can still select hidden options with arrow keys
   */

  //create fake select
  fake_select=$('<select id="fake_select"></select>').appendTo('body').hide()

  var last_model_options=null;

  var selected_option=model_options.filter('option:selected') //get selected
  if(selected_option.length>0){
    //if model is selected on load, select related brand/group
    brand_select.val(selected_option.attr('name'))
    model_options.filter('[name!='+brand_select.val()+']').appendTo(fake_select)
    //eg. last selected options were all toyota models
    last_model_options=model_select.find('option[name]')
  }
  else if(brand_select.val()){
    //if brand is selected on load, hide all except preselected by brand value
    model_options.filter('[name!='+brand_select.val()+']').appendTo(fake_select)
    //eg. last selected options were all toyota models
    last_model_options=model_select.find('option[name]')
  }
  else{
    //if no brand selected on load, disable model select box and hide all options
    model_select.attr('disabled',true)

    //create fake select and dump all model_options to it
    model_options.appendTo(fake_select)
  }
  //var temp = $(json0.temp_value)
  brand_select.change(function(e){
    var brand_option_val=$(this).val()
    if(brand_option_val){
      //chosen brand has a value, so show model select options
      model_select.removeAttr('disabled')

      if(last_model_options && last_model_options.length){
        //if previous visible options exists, hide them
        //append previous model options to hidden fake select
        last_model_options.appendTo(fake_select)
      }

      //get selected model options
      last_model_options=model_options.filter('[name='+brand_option_val+']')

      last_model_options.appendTo(model_select)

      //select blank option
      //if(temp=='')
      model_select.val('')
      //else model_select.val(temp)
    }
    else{
      //no brand value, so disable model select options
      model_select.attr('disabled',true)
    }
  })
}