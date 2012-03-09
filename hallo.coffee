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
      modified: ->
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
      'hallo:modified'    : 'modified'

    _bindUserCallbacks: ->
      for event, callback of @_userCallbacks
        @element.on event, this, @options[callback]

    _prepareToolbar: ->
      @toolbar = $("<div />").addClass(@options.toolbarClass).
        appendTo('body').
        hide().
        draggable().
        position
          my: 'right bottom'
          at: 'right top'
          of: @element
        window.toolbar = @toolbar

    _classEvents:
      'focus click'       : '_activateEditMode'
      'blur'              : '_deactivateEditMode'
      'keyup paste change': '_checkModified'
      'keyup'             : '_checkEscape'
      'keyup mouseup'     : '_setSelection'

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
      selection = rangy.getSelection()
      if selection.rangeCount > 0
        return selection.getRangeAt(0)
      else
        return null

    restoreSelection: (range) ->
      rangy.getSelection().setSingleRange(range)

    replaceSelection: (callback) ->
      range = @getSelection()
      newTextNode = document.createTextNode(callback(range.extractContents()))
      range.insertNode(newTextNode)
      range.setStartAfter(newTextNode)
      @restoreSelection(range)

    removeAllSelections: () ->
      rangy.getSelection().removeAllRanges()

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

    _checkModified: (e) ->
      e.data._checkModifiedInContext()

    _checkModifiedInContext: ->
      if @isModified()
        @_trigger "hallo:modified", null,
          editable: this
          content: @getContents()

    _checkEscape: (e) ->
      if e.keyCode == 27
        e.data.restoreOriginalContent()
        e.data.element.blur()

    _rangesEqual: (r1, r2) ->
      r1 and r2 and r1.equals(r2)

    # Check if some text is selected, and if this selection has changed. If it changed,
    # trigger the "halloselected" event
    _setSelection: (e) ->
      e.data._setSelectionInContext(e) unless e.keyCode == 27
    
    _setSelectionInContext: (event) ->
      # The mouseup event triggers before the text selection is updated.
      # I did not find a better solution than setTimeout in 0 ms
      setTimeout =>
        range = @getSelection()
        if ((range is null) or @_isEmptyRange(range)) and @selection
          @selection = null
          @_trigger "hallo:unselected", null,
              editable: this
              originalEvent: event
        else if range and !@_rangesEqual(range, @selection)
          @selection = range.cloneRange()
          @_trigger "hallo:selected", null,
            editable: this
            selection: @selection
            originalEvent: event
      , 0

    _isEmptyRange: (range) ->
      range.collapsed

    _generateUUID: ->
      S4 = ->
        ((1 + Math.random()) * 0x10000|0).toString(16).substring 1
      "#{S4()}#{S4()}-#{S4()}-#{S4()}-#{S4()}-#{S4()}#{S4()}#{S4()}"

  }


)(jQuery)
