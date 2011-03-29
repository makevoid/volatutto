

$(function(){
    
  var template = $("#result_tmpl").html()

  function do_search() {
    data = $("form#search").serialize()
    //console.log(data)
    $("#spinner").show("fast")
    $("#results").fadeOut("fast")
    $.ajax({
      url: "/search.json",
      dataType: 'json',
      type: "POST",
      data: data,
      success: function(data){    
        $("#spinner").hide()
        $("#results").fadeIn("fast")
        
        var html = Mustache.to_html(template, data)
        $("#results").html(html)
      }
    }) 
  }
  
  function prevent_default(event) {
    event.preventDefault ? event.preventDefault() : event.returnValue = false
    if(event.preventDefault){ event.preventDefault()}
       else{event.stop()}
    
    event.stopPropagation()
  }
  
  $("form#search").live('submit', function(e){
    do_search()
    
    prevent_default(e)
    return false
  })
  
  $("form#search input.submit").click(function(e){
    do_search()
    prevent_default(e)
    return false
  })

  
})

/*
* - API - 
* POST /search.json - returns an array of flights
*
* { 
*   results: [
*     {
*       "start_date": "15/6/2011",
*       "end_date":   "15/7/2011",
*       "price": "123",
*       "link": "http://..."
*     },
*/