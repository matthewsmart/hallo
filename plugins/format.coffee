#     Hallo - a rich text editing jQuery UI widget
#     (c) 2011 Henri Bergius, IKS Consortium
#     Hallo may be freely distributed under the MIT license
((jQuery) ->
    jQuery.widget "IKS.halloformat",
      options:
        editable: null
        toolbar: null
        uuid: ""
        formattings:
          bold: true
          italic: true
          strikeThrough: true
          underline: true

      _create: ->
        @buttonset = $("<span class=\"#{@widgetName}\"></span>")
          
        for command, enabled of @options.formattings
          label = command.substr(0, 1).toUpperCase()
          @_createButton(command, label) if enabled
        
        @_createButton('removeFormat', '--')

        @buttonset.buttonset()
        @options.toolbar.append @buttonset

      _init: ->

      _createButton: (command, label) ->
        id = "#{@options.uuid}-#{command}"
        @buttonset.append $("<input id=\"#{id}\" type=\"button\" value=\"#{label}\"/>").button()
        button = $("##{id}", @buttonset)
        button.data "hallo-command", command
        button.on "click", (e) =>
          command = $(e.currentTarget).data "hallo-command"
          @options.editable.execute command, false
          e.preventDefault()
          return false

)(jQuery)
