define (require, exports, module)->
  Backbone = require "backbone"
  MixinBackbone = require "backbone-mixin"
  require "epoxy"

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

    bindings:
      ":el": "text: text, classes: {active: active}"

    events:
      "click": "onClick"

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

    bindings:
      "@ui.menu": "collection: $collection"

    events:
      "click": "onClick"

    initialize: ->
      @collection = new DropDownCollection
      @listenTo @collection, "change:active", @onChangeCollectionActive
      @currentActiveModel = null

    bindToInput: (@$input)->

    setButtonText: (text)->
      @ui.button.text text

    setData: (data)->
      @collection.remove @collection.models
      @collection.add data

    onClick: ->
      @$el.toggleClass "open"

    onChangeCollectionActive: (model,value)->
      return unless value
      @currentActiveModel?.set active:false
      @currentActiveModel = model
      @$input.val model.get "value"
      @$input.trigger "change"
      @setButtonText model.get "text"
