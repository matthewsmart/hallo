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
            
          for format, enabled of @options.formattings
            @_createButton(format) if enabled

          @buttonset.buttonset()
          @options.toolbar.append @buttonset

        _init: ->

        _createButton: (format) ->
          label = format.substr(0, 1).toUpperCase()
          id = "#{@options.uuid}-#{format}"
          @buttonset.append $("<input id=\"#{id}\" type=\"button\" value=\"#{label}\"/>").button()
          button = $("##{id}", @buttonset)
          button.data "hallo-command", format
          button.on "click", (e) =>
            console.log e
            command = $(e.currentTarget).data "hallo-command"
            @options.editable.execute command
            e.preventDefault()
            return false


)(jQuery)
