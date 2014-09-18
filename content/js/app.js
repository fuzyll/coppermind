$( document).ready(function () {
	$("input:submit").click(function(event){
		var clickEvent = event
		$("input").each(function(){
			if($(this).prop("required") && $(this).text() == "")
			{
				clickEvent.preventDefault();
				alert("You are missing a required field.");
			}
		});
	});
});
