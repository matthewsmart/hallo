#     Hallo - a rich text editing jQuery UI widget
#     (c) 2011 Henri Bergius, IKS Consortium
#     Hallo may be freely distributed under the MIT license
((jQuery) ->
  # Hallo provides a jQuery UI widget `hallo`. Usage:
  #
  #     jQuery('p').hallo();
  #
  # Getting out of the editing state:
  #
  #     jQuery('p').hallo({editable: false});
  #
  # When content is in editable state, users can just click on
  # an editable element in order to start modifying it. This
  # relies on browser having support for the HTML5 contentEditable
  # functionality, which means that some mobile browsers are not
  # supported.
  #
  # If plugins providing toolbar buttons have been enabled for
  # Hallo, then a floating editing toolbar will be rendered above
  # the editable contents when an area is active.
  #
  # ## Options
  #
  # Change from floating mode to relative positioning with using
  # the offset to position the toolbar where you want it:
  #
  #    jQuery('selector').hallo({
  #       floating: true,
  #       offset: {
  #         'x' : 0,
  #         'y' : 0
  #       }
  #    });
  #
  # Force the toolbar to be shown at all times when a contenteditable
  # element is focused:
  #
  #    jQuery('selector').hallo({
  #       showAlways: true
  #    });
  #
  # showAlways is false by default
  #
  # ## Events
  #
  # The Hallo editor provides several jQuery events that web
  # applications can use for integration:
  #
  # ### Activated
  #
  # When user activates an editable (usually by clicking or tabbing
  # to an editable element), a `hallo:activated` event will be fired.
  #
  #     jQuery('p').bind('hallo:activated', function() {
  #         console.log("Activated");
  #     });
  #
  # ### Deactivated
  #
  # When user gets out of an editable element, a `hallo:deactivated`
  # event will be fired.
  #
  #     jQuery('p').bind('hallo:deactivated', function() {
  #         console.log("Deactivated");
  #     });
  #
  # ### Modified
  #
  # When contents in an editable have been modified, a
  # `hallomodified` event will be fired.
  #
  #     jQuery('p').bind('hallomodified', function(event, data) {
  #         console.log("New contents are " + data.content);
  #     });
  #
  jQuery.widget "IKS.hallo", {
    toolbar: null
    bound: false
    originalContent: ""
    uuid: ""
    selection: null

    options:
      editable: true
      plugins: {}
      activated: ->
      deactivated: ->
      enabled: ->
      disabled: ->
      selected: ->
      unselected: ->
      placeholder: ''
      toolbarClass: 'hallo_toolbar'

    _create: ->
      @originalContent = @getContents()
      @id = @_generateUUID()
      @_bindUserCallbacks()
      @_prepareToolbar()
      for plugin, options of @options.plugins
        options = {} unless jQuery.isPlainObject(options)
        options["editable"] = this
        options["toolbar"] = @toolbar
        options["uuid"] = @id
        # Call individual plugins
        @element[plugin](options)

    _init: ->
      if @options.editable
        @enable()
      else
        @disable()

    _userCallbacks:
      'hallo:activated'   : 'activated'
      'hallo:deactivated' : 'deactivated'
      'hallo:enabled'     : 'enabled'
      'hallo:disabled'    : 'disabled'
      'hallo:selected'    : 'selected'
      'hallo:unselected'  : 'unselected'

    _bindUserCallbacks: ->
      for event, callback of @_userCallbacks
        @element.on event, this, @options[callback]

    _prepareToolbar: ->
      @toolbar_class = @options.toolbarClass
      @toolbar = $("<div class=\"#{@toolbar_class}\"></div>").hide()
      $('body').append(@toolbar)

    _classEvents:
      'focus click'       : '_activateEditMode'
      'blur'              : '_deactivateEditMode'
      'keyup paste change': '_checkModified'
      'keyup'             : '_checkEscape'
      'keyup mouseup'     : '_checkSelection'

    # Enable an editable
    enable: ->
      # Set Editable
      @element.attr "contentEditable", true
      # Manage Placeholder
      @_insertPlaceholder()
      # Don't double bind events
      if not @bound
        for event, callback of @_classEvents
          @element.on event, this, @[callback]
        @bound = true
      # Show toolbar
      console.log 'fading in toolbar'
      @toolbar.fadeIn()
      # Trigger user event
      @_trigger 'hallo:enabled'

    # Disable an editable
    disable: ->
      # Set Editable
      @element.attr "contentEditable", false
      # Manage Placeholder
      @_removePlaceholder()
      # Unbind events
      for event, callback of @_classEvents
        @element.off event, @[callback]
      @bound = false
      # Show toolbar
      @toolbar.fadeOut()
      # Trigger user event
      @_trigger "hallo:disabled"

    _activateEditMode: (e) ->
      console.log e
      e.data.activateEditMode()

    activateEditMode: ->
      # Take care of the place holder
      @_removePlaceholder()
      # Add the class
      @element.addClass 'inEditMode'
      # Trigger the user event
      @_trigger "hallo:activated"

    _deactivateEditMode: (e) ->
      e.data.deactivateEditMode()

    deactivateEditMode: () ->
      # Take care of the place holder
      @_insertPlaceholder()
      # Remove the class
      @element.removeClass 'inEditMode'
      # Trigger the user event
      @_trigger "hallo:deactivated"

    _removePlaceholder: ->
      if @getContents() is @options.placeholder
        @setContents ''

    _insertPlaceholder: ->
      if @getContents() is ''
        @setContents @options.placeholder

    # Only supports one range for now (i.e. no multiselection)
    getSelection: ->
      if jQuery.browser.msie
        range = document.selection.createRange()
      else
        if window.getSelection
          userSelection = window.getSelection()
        else if (document.selection) #opera
          userSelection = document.selection.createRange()
        else
          throw "Your browser does not support selection handling"

        if userSelection.rangeCount > 0
          range = userSelection.getRangeAt(0)
        else
          range = userSelection

      return range

    restoreSelection: (range) ->
      if ( jQuery.browser.msie )
        range.select()
      else
        window.getSelection().removeAllRanges()
        window.getSelection().addRange(range)

    replaceSelection: (cb) ->
      if ( jQuery.browser.msie )
        t = document.selection.createRange().text
        r = document.selection.createRange()
        r.pasteHTML(cb(t))
      else
        sel = window.getSelection()
        range = sel.getRangeAt(0)
        newTextNode = document.createTextNode(cb(range.extractContents()))
        range.insertNode(newTextNode)
        range.setStartAfter(newTextNode)
        sel.removeAllRanges()
        sel.addRange(range)

    removeAllSelections: () ->
      if ( jQuery.browser.msie )
        range.empty()
      else
        window.getSelection().removeAllRanges()

    # Get contents of an editable as HTML string
    getContents: ->
      @element.html()

    # Set the contents of an editable
    setContents: (contents) ->
      @element.html contents

    # Check whether the editable has been modified
    isModified: ->
      @originalContent isnt @getContents()

    # Set the editable as unmodified
    setUnmodified: ->
      @originalContent = @getContents()

    # Restore the content original
    restoreOriginalContent: ->
      @element.html(@originalContent)

    # Execute a contentEditable command
    execute: (command, value) ->
      if document.execCommand command, false, value
        @element.trigger "change"

    _generateUUID: ->
      S4 = ->
        ((1 + Math.random()) * 0x10000|0).toString(16).substring 1
      "#{S4()}#{S4()}-#{S4()}-#{S4()}-#{S4()}-#{S4()}#{S4()}#{S4()}"

    _getCaretPosition: (range) ->
      tmpSpan = jQuery "<span/>"
      newRange = document.createRange()
      newRange.setStart range.endContainer, range.endOffset
      newRange.insertNode tmpSpan.get 0

      position = {top: tmpSpan.offset().top, left: tmpSpan.offset().left}
      tmpSpan.remove()
      return position


    _checkModified: (event) ->
      widget = event.data
      if widget.isModified()
        widget._trigger "modified", null,
          editable: widget
          content: widget.getContents()

    _keys: (e) ->
      if e.keyCode == 27
        e.data.restoreOriginalContent()
        e.data.deactivateEditor()

    _rangesEqual: (r1, r2) ->
      r1.startContainer is r2.startContainer and r1.startOffset is r2.startOffset and r1.endContainer is r2.endContainer and r1.endOffset is r2.endOffset

    # Check if some text is selected, and if this selection has changed. If it changed,
    # trigger the "halloselected" event
    _checkSelection: (event) ->
      if event.keyCode == 27
        return

      widget = event.data

      # The mouseup event triggers before the text selection is updated.
      # I did not find a better solution than setTimeout in 0 ms
      setTimeout ()->
        sel = widget.getSelection()
        if widget._isEmptySelection(sel) or widget._isEmptyRange(sel)
          if widget.selection
            widget.selection = null
            widget._trigger "hallo:unselected", null,
              editable: widget
              originalEvent: event
          return

        if !widget.selection or not widget._rangesEqual sel, widget.selection
          widget.selection = sel.cloneRange()
          widget._trigger "hallo:selected", null,
            editable: widget
            selection: widget.selection
            ranges: [widget.selection]
            originalEvent: event
      , 0

    _isEmptySelection: (selection) ->
      if selection.type is "Caret"
        return true

      return false

    _isEmptyRange: (range) ->
      if range.collapsed
        return true
      if range.isCollapsed
        return range.isCollapsed()

      return false

  }


)(jQuery)
