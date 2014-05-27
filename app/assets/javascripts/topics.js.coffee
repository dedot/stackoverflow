$ ->
  if $('#topic_tags').length > 0
    $.get '/tags.json', (data) ->
      $('#topic_tags').select2
        tags: data
        tokenSeparators: [",", " "]

  cleanup = (form) ->
    form.find('textarea,input[type="text"],input[type="file"]').val('')
    form.find('.form-group').removeClass('has-error')
    form.find('.help-block').remove()

  $('main')
  
  .on 'focus', '.select2-container input', (e) ->
    $(this).closest('.select2-choices').addClass('focus')

  .on 'blur', '.select2-container input', (e) ->
    $(this).closest('.select2-choices').removeClass('focus')

  .on 'click', '.add-comment', (e) ->
    e.preventDefault()
    if $(this).hasClass('disabled')
      alert = $(this).siblings('.alert')
      if alert.length == 0
        $(this).after( JST['alert/comment']() )
      else
        alert.effect('bounce')
    else
      id = $(this).attr('data-message-id')
      $('.add-comment').show() # all other links
      $form = $('#new_comment').detach()
      cleanup($form)
      $form.attr('action',"/messages/#{id}/comments")
      $(this).hide().after($form)
      $form.show()

  .on 'click', '.cancel-comment', (e) ->
    e.preventDefault()
    $(this).parent().hide().siblings('a').show()

  .on 'ajax:success', '#new_comment', (evt, data, status, xhr) ->
    $form = $(this)
    $comments = $form.parent()
    cleanup($form)

    commentObject = $.parseJSON(xhr.responseText)
    commentHtml = JST['comment'](commentObject)
    list = $comments.find('.comments-list')
    list.append(commentHtml).find('time').timeago()

    $form.hide()
    $comments.find('.add-comment').show();

  .on 'ajax:error', '#new_comment', (evt, xhr, status, error) ->
    $form = $(this)
    cleanup($form)
    errors = $.parseJSON(xhr.responseText)
    for own key, value of errors.errors
      group = $form.find("#comment_#{key}").parent()
      group.addClass('has-error')
      group.append( JST['field_error']({error: value}) )

  .on 'click', '.answer-link', (e) ->
    href = $(this).attr('href').match(/(#.+)/)[0]
    $(href).stop()
      .animate({backgroundColor:'lightyellow'}, 500)
      .animate({backgroundColor:'white'}, 500)