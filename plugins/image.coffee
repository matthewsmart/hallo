((jQuery) ->
  jQuery.widget "lat.erality_image",
    options:
      editable: null
      toolbar: null
      uuid: ""
      dialogOptions:
        autoOpen: false
        width: 540
        title: "Add an Image"
        modal: true
        resizable: false
        draggable: false
        dialogClass: 'lateralityimage-dialog'

    _create: ->
      @dialog         = @_dialog()
      @url_field      = @_urlField()
      @ok_button      = @_okButton()
      @cancel_button  = @_cancelButton()
      @modes          = @_modes()

      @dialog.
        append(@url_field).
        append(@modes).
        append(@cancel_button).
        append(@ok_button)

      @options.toolbar.append @_toolbarButton()

    _dialog: ->
      dialog_id = "#{@options.uuid}-dialog"
      $("<div id\"#{dialog_id}\" />").dialog @options.dialogOptions

    _urlField: ->
      field_id = "#{@options.uuid}-url"
      $("<span><label for=\"#{field_id}\">Image URL:</label><input type=\"text\" value=\"Link to image...\" id=\"#{field_id}\"/></span>")

    _getURL: ->
      @url_field.find('input').val()

    _okButton: ->
      $('<button>OK</button>').on 'click', (e) =>
        @_ok()
        e.preventDefault()
        false

    _cancelButton: ->
      $('<button>CANCEL</button>').on 'click', (e) =>
        @_cancel()
        e.preventDefault()
        false

    _modes: ->
      @mode_group = "#{@options.uuid}-mode"
      left_id = "#{@mode_group}_left"
      left = $("<input name=\"#{@mode_group}\" type=\"radio\" id=\"#{left_id}\" value=\"left\" /><label for=\"#{left_id}\">FLOAT LEFT</label>")
      block_id = "#{@mode_group}_block"
      block = $("<input name=\"#{@mode_group}\" type=\"radio\" id=\"#{block_id}\" value=\"block\" checked=\"checked\" /><label for=\"#{block_id}\">BLOCK</label>")
      right_id = "#{@mode_group}_right"
      right = $("<input name=\"#{@mode_group}\" type=\"radio\" id=\"#{right_id}\" value=\"right\" /><label for=\"#{right_id}\">FLOAT RIGHT</label>")
      $("<div id=\"#{@mode_group}\" />").
        append(left).
        append(block).
        append(right).
        buttonset()

    _getMode: ->
      $("input:radio[name=#{@mode_group}]:checked").val()

    _ok: ->
      console.log 'ok caught'
      url   = @_getURL()
      mode  = @_getMode()
      console.log url
      console.log mode
      # Put the cursor back in case we lost it
      @options.editable.restoreSelection(@selection)
      # Regular image insertion
      if mode is 'block'
        @options.editable.execute 'insertImage', url
      else if mode is 'left'
        html = "<img src=\"#{url}\" style=\"float: left;\" />"
        @options.editable.execute 'insertHTML', html
      else if mode is 'right'
        html = "<img src=\"#{url}\" style=\"float: right;\" />"
        @options.editable.execute 'insertHTML', html
      # Close the dialog
      @dialog.dialog 'close'

    _cancel: ->
      console.log 'cancel caught'
      # Close the dialog
      @dialog.dialog 'close'

    _toolbarButton: ->
      id  = "#{@options.uuid}-image"
      set = $("<span />")
      button = $("<input id=\"#{id}\" type=\"button\" value=\"IMAGE\" />").
        button().on "click", (e) =>
          @selection = @options.editable.getSelection()
          @dialog.dialog 'open'
          e.preventDefault()
          false
      set.append(button).buttonset()

)(jQuery)
