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

    refresh: (data)->
      @set data

    normalize:(txt)->
      txt.toLowerCase().replace /[^a-zа-я0-9]/g, ""

    search: (val)->
      rx = new RegExp "^#{@normalize val}", "g"
      @filter (model)=>
        text = @normalize model.get "text"
        rx.test text

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

    initialize: (options)->
      @search = options.search
      @dataCollection ?= new DropDownCollection
      @collection ?= new DropDownCollection
      @listenTo @collection,
        "change:active": @onChangeCollectionActive
        "add": @onAddCollection
        "remove": @onRemoveCollection
      @currentActiveModel = null
      @isMenuOpen = false
      @views = {}
      @__onBackdropClick = (e)=> @onBackdropClick(e)
      @__onSearch = (e)=> @onSearch(e)

    render: ->
      if @search
        @searchField = $("<input class=dropdown-search placeholder=Найти...>")
        @ui.menu.append @searchField

    onShow:->
      if @search
        @$el.on "change keyup", '.dropdown-search', @__onSearch
      $(window).on "click", @__onBackdropClick

    onClose:->
      if @search
        @$el.off "change keyup", '.dropdown-search', @__onSearch
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
      @dataCollection.refresh data
      @collection.refresh data

    onSearch: ->
      val = @searchField.val()
      searchModels = @dataCollection.search val
      @collection.refresh searchModels

    onClick: (e)->
      return if e.target is @searchField?[0]
      if @isMenuOpen
        @$el.removeClass @OPEN_CLASS
        @isMenuOpen = false
      else
        @searchField?.val("").trigger "change"
        @$el.addClass @OPEN_CLASS
        @isMenuOpen = true
        @searchField?.focus()

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

  DropDownList.version = "0.0.6"
  DropDownList

if (typeof define is 'function') and (typeof define.amd is 'object') and define.amd
  define [
    "backbone"
    'backbone-mixin'
  ], (Backbone, MixinBackbone)->
    Holder Backbone, MixinBackbone
else
  window.DropDown = Holder Backbone, MixinBackbone
