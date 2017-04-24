// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require materialize-sprockets
//= require highcharts
//= require chartkick
//= require jquery.infinite-pages
//= require masonry.pkgd.min
//= require_tree .

$(document).on('turbolinks:load', function(event) {
    // Hacky solution to avoid duplicate material_select on "back".
    $('select').material_select();
    $('.select-wrapper:not(:first-child)').remove();

    Materialize.updateTextFields();

    // Alert boxes
    $('.alert-close').click(function(event){
        $(event.target).closest('.alert-box').fadeOut("slow", function() {});
    });

    $('.infinite-list').infinitePages();

    $('.grid').masonry({
        itemSelector: '.grid-item',
        columnWidth: 400,
        gutter: 20
    });

    // Left menu
    sections = $('.main-body .content [data-section]');
    sections.hide()
    $('.left-menu li[data-section="Overview"]').addClass('active')
    sections.filter('[data-section="Overview"]').show()

    $('.left-menu li').click(function(event){
        $('.left-menu li').removeClass('active')
        $(event.currentTarget).addClass('active')
        var section = $(event.currentTarget).data('section');
        sections.hide();
        sections.filter('[data-section="'+section+'"]').show()
        window.dispatchEvent(new Event('resize'));
    });

    // Stats
    $('.stat .card-action .action').click(function(event){
      $stat = $(event.target).closest('.stat')
      $stat.find('.data').toggle();
      $stat.find('.action').toggle();
      $('.grid').masonry();
    });
});


