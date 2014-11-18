(function() {
  var Holder;

  Holder = function(Backbone, MixinBackbone) {
    var DropDownCollection, DropDownItem, DropDownList, DropDownModel, View;
    View = MixinBackbone(Backbone.View);
    DropDownModel = Backbone.Model.extend({
      defaults: {
        text: "",
        value: "",
        active: false
      }
    });
    DropDownCollection = Backbone.Collection.extend({
      model: DropDownModel
    });
    DropDownItem = View.extend({
      className: "dropdown_item",
      tagName: "li",
      events: {
        "click": "onClick"
      },
      initialize: function() {
        this.listenTo(this.model, {
          "change:text": this.onTextChange,
          "change:active": this.onActiveChange
        });
        this.updateText();
        return this.updateActive();
      },
      updateText: function() {
        return this.$el.text(this.model.get("text"));
      },
      updateActive: function() {
        if (this.model.get("active")) {
          return this.$el.addClass("active");
        } else {
          return this.$el.removeClass("active");
        }
      },
      onTextChange: function() {
        return this.updateText();
      },
      onActiveChange: function() {
        return this.updateActive();
      },
      onClick: function() {
        return this.model.set({
          active: true
        });
      }
    });
    DropDownList = View.extend({
      className: "dropdown_list",
      itemView: DropDownItem,
      templateFunc: function() {
        return "<button class=dropdown-list-button type='button' data-js-button></button> <ul class=dropdown-list-menu data-js-menu></ul>";
      },
      ui: {
        menu: "[data-js-menu]",
        button: "[data-js-button]"
      },
      events: {
        "click": "onClick"
      },
      initialize: function() {
        this.collection = new DropDownCollection;
        this.listenTo(this.collection, {
          "change:active": this.onChangeCollectionActive,
          "add": this.onAddCollection,
          "remove": this.onRemoveCollection
        });
        this.currentActiveModel = null;
        return this.views = {};
      },
      bindToInput: function($input) {
        this.$input = $input;
      },
      setButtonText: function(text) {
        return this.ui.button.text(text);
      },
      setData: function(data) {
        this.collection.remove(this.collection.models);
        return this.collection.add(data);
      },
      onClick: function() {
        return this.$el.toggleClass("open");
      },
      onAddCollection: function(model) {
        var itemView;
        this.views[model.cid] = itemView = new this.itemView({
          model: model
        });
        return this.ui.menu.append(itemView.$el);
      },
      onRemoveCollection: function(model) {
        return this.views[model.cid].remove();
      },
      onChangeCollectionActive: function(model, value) {
        var _ref;
        if (!value) {
          return;
        }
        if ((_ref = this.currentActiveModel) != null) {
          _ref.set({
            active: false
          });
        }
        this.currentActiveModel = model;
        this.$input.val(model.get("value"));
        this.$input.trigger("change");
        return this.setButtonText(model.get("text"));
      }
    });
    DropDownList.version = "0.0.3";
    return DropDownList;
  };

  if ((typeof define === 'function') && (typeof define.amd === 'object') && define.amd) {
    define(["backbone", 'backbone-mixin'], function(Backbone, MixinBackbone) {
      return Holder(Backbone, MixinBackbone);
    });
  } else {
    window.DropDown = Holder(Backbone, MixinBackbone);
  }

}).call(this);
