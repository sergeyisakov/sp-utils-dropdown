(function() {
  var Holder;

  Holder = function(Backbone, MixinBackbone) {
    var $, DropDownCollection, DropDownItem, DropDownList, DropDownModel, View;
    View = MixinBackbone(Backbone.View);
    $ = Backbone.$;
    DropDownModel = Backbone.Model.extend({
      defaults: {
        text: "",
        value: "",
        active: false
      }
    });
    DropDownCollection = Backbone.Collection.extend({
      model: DropDownModel,
      refresh: function(data) {
        return this.set(data);
      },
      normalize: function(txt) {
        return txt.toLowerCase().replace(/[^a-zа-я0-9]/g, "");
      },
      search: function(val) {
        var rx;
        rx = new RegExp("^" + (this.normalize(val)), "g");
        return this.filter((function(_this) {
          return function(model) {
            var text;
            text = _this.normalize(model.get("text"));
            return rx.test(text);
          };
        })(this));
      }
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
      OPEN_CLASS: "open",
      className: "dropdown_list",
      itemView: DropDownItem,
      templateFunc: function() {
        return "<button class=dropdown-list-button type='button'></button> <ul class=dropdown-list-menu></ul>";
      },
      ui: {
        menu: ".dropdown-list-menu",
        button: ".dropdown-list-button"
      },
      events: {
        "click": "onClick"
      },
      initialize: function(options) {
        this.search = options.search;
        if (this.dataCollection == null) {
          this.dataCollection = new DropDownCollection;
        }
        if (this.collection == null) {
          this.collection = new DropDownCollection;
        }
        this.listenTo(this.collection, {
          "change:active": this.onChangeCollectionActive,
          "add": this.onAddCollection,
          "remove": this.onRemoveCollection
        });
        this.currentActiveModel = null;
        this.isMenuOpen = false;
        this.views = {};
        this.__onBackdropClick = (function(_this) {
          return function(e) {
            return _this.onBackdropClick(e);
          };
        })(this);
        return this.__onSearch = (function(_this) {
          return function(e) {
            return _this.onSearch(e);
          };
        })(this);
      },
      render: function() {
        if (this.search) {
          this.searchField = $("<input class=dropdown-search placeholder=Найти...>");
          return this.ui.menu.append(this.searchField);
        }
      },
      onShow: function() {
        if (this.search) {
          this.$el.on("change keyup", '.dropdown-search', this.__onSearch);
        }
        return $(window).on("click", this.__onBackdropClick);
      },
      onClose: function() {
        if (this.search) {
          this.$el.off("change keyup", '.dropdown-search', this.__onSearch);
        }
        return $(window).off("click", this.__onBackdropClick);
      },
      updateCollectionActive: function(model) {
        var _ref;
        if (!model.get("active")) {
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
      },
      bindToInput: function($input) {
        this.$input = $input;
      },
      setButtonText: function(text) {
        return this.ui.button.text(text);
      },
      setData: function(data) {
        this.dataCollection.refresh(data);
        return this.collection.refresh(data);
      },
      onSearch: function() {
        var searchModels, val;
        val = this.searchField.val();
        searchModels = this.dataCollection.search(val);
        return this.collection.refresh(searchModels);
      },
      onClick: function(e) {
        var _ref, _ref1, _ref2;
        if (e.target === ((_ref = this.searchField) != null ? _ref[0] : void 0)) {
          return;
        }
        if (this.isMenuOpen) {
          this.$el.removeClass(this.OPEN_CLASS);
          return this.isMenuOpen = false;
        } else {
          if ((_ref1 = this.searchField) != null) {
            _ref1.val("").trigger("change");
          }
          this.$el.addClass(this.OPEN_CLASS);
          this.isMenuOpen = true;
          return (_ref2 = this.searchField) != null ? _ref2.focus() : void 0;
        }
      },
      onBackdropClick: function(e) {
        var isListClick;
        isListClick = $(e.target).parents("." + this.className)[0] === this.el;
        if (isListClick || !this.isMenuOpen) {
          return;
        }
        this.$el.removeClass(this.OPEN_CLASS);
        return this.isMenuOpen = false;
      },
      onAddCollection: function(model) {
        var itemView;
        this.views[model.cid] = itemView = new this.itemView({
          model: model
        });
        this.ui.menu.append(itemView.$el);
        return this.updateCollectionActive(model);
      },
      onRemoveCollection: function(model) {
        return this.views[model.cid].remove();
      },
      onChangeCollectionActive: function(model) {
        return this.updateCollectionActive(model);
      }
    });
    DropDownList.version = "0.0.6";
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
