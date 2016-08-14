// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).ready(function(){
	$('body').on('click', '.extract-email-button', function(){
		var base_url = $('.base_url_field').val();
		var request_url = $(this).data( "url" );
		send_ajax_request("post", 
			request_url,
			"json",
			{
				base_url: base_url
			},
			function(data){
				$('.refersh-records').data('query', data);
			},
			function(jqXHR, exception){
				console.log(exception);
			}
		);
	})

	$('body').on('click', '.refersh-records', function(){
		var query_id = $(this).data('query');
		var request_url = $(this).data('url');
		if(query_id){
			send_ajax_request("post", 
				request_url,
				"html",
				{
					query_id: query_id
				},
				function(data){
					$('#recors-div').html(data);
				},
				function(jqXHR, exception){
					console.log(exception);
				}
			);	
		}
	})
})

function send_ajax_request(req_type, req_url, data_type, req_data, success_callback, error_callback){
	$.ajax({
		type: req_type,
		url: req_url,
		dataType: data_type,
		data: req_data,
		success: success_callback,
		error: error_callback
	});
}