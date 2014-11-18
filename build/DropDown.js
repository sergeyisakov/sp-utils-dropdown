define(function(require, exports, module) {
  var Backbone, DropDownCollection, DropDownItem, DropDownList, DropDownModel, MixinBackbone, View;
  Backbone = require("backbone");
  MixinBackbone = require("backbone-mixin");
  require("epoxy");
  View = MixinBackbone(Backbone.Epoxy.View);
  DropDownModel = Backbone.Epoxy.Model.extend({
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
    bindings: {
      ":el": "text: text, classes: {active: active}"
    },
    events: {
      "click": "onClick"
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
    bindings: {
      "@ui.menu": "collection: $collection"
    },
    events: {
      "click": "onClick"
    },
    initialize: function() {
      this.collection = new DropDownCollection;
      this.listenTo(this.collection, "change:active", this.onChangeCollectionActive);
      return this.currentActiveModel = null;
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
  DropDownList.version = "0.0.2";
  return DropDownList;
});
