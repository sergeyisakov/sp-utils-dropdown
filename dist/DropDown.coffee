define (require, exports, module)->
  Backbone = require "backbone"
  MixinBackbone = require "backbone-mixin"

  View = MixinBackbone Backbone.Epoxy.View

#------------------- model ---------------------------#
  DropDownModel = Backbone.Epoxy.Model.extend
    defaults:
      text: ""
      value: ""
      active: false

#------------------- collection ----------------------#
  DropDownCollection = Backbone.Collection.extend
    model: DropDownModel

#------------------- item ----------------------------#
  DropDownItem = View.extend
    className: "dropdown_item"
    tagName: "li"

    events:
      "click": "onClick"

    initialize: ->
      @listenTo @model,
        "change:text": @onTextChange
        "change:active": @onActiveChange
      @updateText()
      @updateActive()

    updateText: ->
      @$el.text @model.get "text"

    updateActive: ->
      if @model.get "active"
        @$el.addClass "active"
      else
        @$el.removeClass "active"

    onTextChange: ->
      @updateText()

    onActiveChange: ->
      @updateActive()

    onClick: ->
      @model.set active:true

#------------------- list ----------------------------#
  DropDownList = View.extend
    className: "dropdown_list"
    itemView: DropDownItem

    templateFunc: ->
      "
        <button class=dropdown-list-button type='button' data-js-button></button>
        <ul class=dropdown-list-menu data-js-menu></ul>
      "

    ui:
      menu: "[data-js-menu]"
      button: "[data-js-button]"

    events:
      "click": "onClick"

    initialize: ->
      window.aaa = @
      @collection = new DropDownCollection
      @listenTo @collection,
        "change:active": @onChangeCollectionActive
        "add": @onAddCollection
        "remove": @onRemoveCollection
      @currentActiveModel = null
      @views = {}

    bindToInput: (@$input)->

    setButtonText: (text)->
      @ui.button.text text

    setData: (data)->
      @collection.remove @collection.models
      @collection.add data

    onClick: ->
      @$el.toggleClass "open"

    onAddCollection: (model)->
      @views[model.cid] = itemView = new @itemView {model}
      @ui.menu.append itemView.$el

    onRemoveCollection: (model)->
      @views[model.cid].remove()

    onChangeCollectionActive: (model, value)->
      return unless value
      @currentActiveModel?.set active:false
      @currentActiveModel = model
      @$input.val model.get "value"
      @$input.trigger "change"
      @setButtonText model.get "text"

  DropDownList.version = "0.0.2"
  DropDownList
