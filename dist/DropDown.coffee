Holder = (Backbone, MixinBackbone)->
  View = MixinBackbone Backbone.View
  $ = Backbone.$

#------------------- model ---------------------------#
  DropDownModel = Backbone.Model.extend
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
      @model.set active: true

#------------------- list ----------------------------#
  DropDownList = View.extend
    OPEN_CLASS: "open"
    className: "dropdown_list"
    itemView: DropDownItem

    templateFunc: ->
      "
        <button class=dropdown-list-button type='button'></button>
        <ul class=dropdown-list-menu></ul>
      "

    ui:
      menu: ".dropdown-list-menu"
      button: ".dropdown-list-button"

    events:
      "click": "onClick"

    initialize: ->
      @collection ?= new DropDownCollection
      @listenTo @collection,
        "change:active": @onChangeCollectionActive
        "add": @onAddCollection
        "remove": @onRemoveCollection
      @currentActiveModel = null
      @isMenuOpen = false
      @views = {}
      @__onBackdropClick = (e)=> @onBackdropClick(e)

    onShow:->
      $(window).on "click", @__onBackdropClick

    onClose:->
      $(window).off "click", @__onBackdropClick

    updateCollectionActive: (model)->
      return unless model.get "active"
      @currentActiveModel?.set active:false
      @currentActiveModel = model
      @$input.val model.get "value"
      @$input.trigger "change"
      @setButtonText model.get "text"

    bindToInput: (@$input)->

    setButtonText: (text)->
      @ui.button.text text

    setData: (data)->
      @collection.remove @collection.models
      @collection.add data

    onClick: (e)->
      if @isMenuOpen
        @$el.removeClass @OPEN_CLASS
        @isMenuOpen = false
      else
        @$el.addClass @OPEN_CLASS
        @isMenuOpen = true

    onBackdropClick: (e)->
      isListClick = $(e.target).parents(".#{@className}")[0] is @el
      return if isListClick or not @isMenuOpen
      @$el.removeClass @OPEN_CLASS
      @isMenuOpen = false

    onAddCollection: (model)->
      @views[model.cid] = itemView = new @itemView {model}
      @ui.menu.append itemView.$el
      @updateCollectionActive model

    onRemoveCollection: (model)->
      @views[model.cid].remove()

    onChangeCollectionActive: (model)->
      @updateCollectionActive model

  DropDownList.version = "0.0.5"
  DropDownList

if (typeof define is 'function') and (typeof define.amd is 'object') and define.amd
  define [
    "backbone"
    'backbone-mixin'
  ], (Backbone, MixinBackbone)->
    Holder Backbone, MixinBackbone
else
  window.DropDown = Holder Backbone, MixinBackbone
