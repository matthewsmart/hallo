((jQuery) ->
  jQuery.widget "lat.ciao_image_from_list",
    options:
      editable: null
      toolbar: null
      uuid: ""
      image_list: []
      dialog: null
      result: null
      selection: null
      dialogOptions:
        autoOpen: false
        width: 540
        height: 500
        title: "Enter Link"
        modal: true
        resizable: false
        draggable: false
        dialogClass: 'ciao_image_from_list-dialog'

    _create: ->
      @dialog = @_prepareDialogElement().dialog(@options.dialogOptions)
      @dialog.on 'dialogclose', =>
        @_insertImage()
      @buttonset = $("<span class=\"#{@widgetName}\"></span>")
      @_createButton()
      @buttonset.buttonset()
      @options.toolbar.append @buttonset

    _prepareDialogElement: ->
      @result = $('<input type="hidden" />')
      @list = @_prepareImageList()
      $('<div />').attr(id: "#{@options.uuid}-dialog").
        append(@list).
        append(@result)
      
      @list.selectable stop: =>
        @_storeResult()

    _storeResult: ->
      @result.val $('.ui-selected', selectable).data('url')

    _prepareImageList: ->
      list = $('<ul />').addClass 'image_list'
      for image in @options.image_list
        $('<li />').append("<img src=\"#{image.thumb}\" />").
          data(url: image.url).
          css(float: 'left').
          appendTo(list)
      list

    _insertImage: ->
      @options.editable.restoreSelection(@selection)
      @options.editable.execute 'insertImage', @result.val()

    _createButton: ->
      id = "#{@options.uuid}-image_from_list"
      label = 'Image From List'
      @buttonset.append $("<input id=\"#{id}\" type=\"button\" value=\"#{label}\"/>").button()
      button = $("##{id}", @buttonset)
      button.on "click", (e) =>
        @selection = @options.editable.getSelection()
        @dialog.dialog 'open'
        e.preventDefault()
        return false

)(jQuery)
