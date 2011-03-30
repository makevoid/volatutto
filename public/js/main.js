$(function(){
  
  function sortColumn(attr) {
    var mylist = $('#results ul')
    var listitems = mylist.children('li').get()
    listitems.sort(function(a, b) {
       var compA = $(a).find("."+attr).text().toUpperCase()
       var compB = $(b).find("."+attr).text().toUpperCase()
       return (compA < compB) ? -1 : (compA > compB) ? 1 : 0
    })
    $.each(listitems, function(idx, itm) { mylist.append(itm); })
  }
  
  $(".legend .price").live('click', function(){
    sortColumn("price")
  })
  $(".legend .start_date").live('click', function(){
    sortColumn("start_date")
  })
  $(".legend .end_date").live('click', function(){
    sortColumn("end_date")
  })
  
})