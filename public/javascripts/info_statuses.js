// Functionality for the information status editing view

var url_without_last_part = new RegExp(/.+\//);

// Embed "private" variables and functions in an ExtJS-style object
var InfoStatus = function() {

    // private variables

    var categories = new Array('new', 'kind', 'acc-gen', 'acc-sit', 'acc-inf', 'old', 'old-inact', 'no-info-status', 'info-unannotatable');
    var non_spec_categories = new Array('non-spec', 'non-spec-inf', 'non-spec-old');
    var annotatables = null;
    var unannotatables = null;
    var selected_token = null;
    var selected_token_index = null;
    var first_numerical_code = 49; // keycode for the 1 key
    var first_alphabetic_code = 88; // keycode for the x key

    // private functions

    /////////////////////////////////////
    //
    // Event handling for annotatables
    //
    /////////////////////////////////////

    function removeEventHandlingForAnnotatables() {
        annotatables.invoke('stopObserving', 'click', annotatableClickHandler);
    }

    function setEventHandlingForAnnotatables() {
        annotatables.invoke('observe', 'click', annotatableClickHandler);
    }

    function annotatableClickHandler(event) {
        if(event.ctrlKey || event.metaKey || event.shiftKey) return;      // we don't handle ctrl-clicks or shift-clicks here
        InfoStatus.selectToken(this);
        event.stop();
    }

    /////////////////////////////////////
    //
    // Event handling for unannotatables
    //
    /////////////////////////////////////

    function removeEventHandlingForUnannotatables() {
        unannotatables.invoke('stopObserving', 'dblclick', unannotatableClickHandler);
    }

    function setEventHandlingForUnannotatables() {
        unannotatables.invoke('observe', 'dblclick', unannotatableClickHandler);
    }

    function unannotatableClickHandler(event) {
        if(event.ctrlKey || event.metaKey || event.shiftKey) return;      // we don't handle ctrl-clicks or shift-clicks here
        makeAnnotatable(this);
        event.stop();
    }

    function makeAnnotatable(elm) {
        if(!confirm('Do you want to make ' + elm.innerHTML + ' annotatable?')) {
            return;
        }
        elm.removeClassName('info-unannotatable');
        elm.addClassName('info-annotatable no-info-status info-changed');
        InfoStatus.setAnnotatablesAndUnannotatables();
        InfoStatus.selectToken(elm);
    }

    /////////////////////////////////////
    //
    // Miscellaneous functions
    //
    /////////////////////////////////////

    function setInfoStatusClass(klass) {
        non_spec_categories.concat(categories).each(function(removed_class) {
            selected_token.removeClassName(removed_class);
        });
        selected_token.addClassName(klass);
        selected_token.addClassName('info-changed');

        if(klass !== 'old' && klass !== 'non-spec-old' && klass !== 'non-spec-inf') {
            var antecedentClass = AnaphoraAndContrast.getAntecedentClassFor(selected_token);
            if(antecedentClass) {
                // Remove anaphoric link if we change info status, since only old tokens can have them
                selected_token.removeClassName(antecedentClass);
                AnaphoraAndContrast.removeAnaphoraLines();
            }
        }
    }

    function setEventHandlingForDocument() {
        document.observe('keydown', function(event) {
            if(!selected_token) return;

            if((event.keyCode >= first_numerical_code && event.keyCode < first_numerical_code + categories.length) || (event.keyCode >= first_alphabetic_code && event.keyCode < first_alphabetic_code + non_spec_categories.length)) {
                var css;
                if (event.keyCode >= first_numerical_code && event.keyCode < first_numerical_code + categories.length) {
                    css = categories[event.keyCode - first_numerical_code];
                }
                else {
                    css = non_spec_categories[event.keyCode - first_alphabetic_code];
                }

                setInfoStatusClass(css);

                if(css == 'info-unannotatable') {
                    selected_token.removeClassName('info-annotatable');
                    selected_token.removeClassName('info-selected');

                    InfoStatus.setAnnotatablesAndUnannotatables();

                    // This will select the next token, since we have just removed the current one
                    // from the annotatables
                    InfoStatus.selectToken(annotatables[selected_token_index === annotatables.length ? 0 : selected_token_index]);
                }
                else if(css != 'old' && css != 'acc-inf' && css != 'non-spec-old' && css != 'non-spec-inf') {
                    InfoStatus.selectToken(annotatables[selected_token_index === annotatables.length - 1 ? 0 : selected_token_index + 1]);
                }

                event.stop();
            }
            else if(event.keyCode === Event.KEY_TAB) {
                var index;

                if(event.shiftKey) {
                    index = selected_token_index === 0 ? annotatables.length - 1 : selected_token_index - 1;
                }
                else {
                    index = selected_token_index === annotatables.length - 1 ? 0 : selected_token_index + 1;
                }
                InfoStatus.selectToken(annotatables[index]);
                event.stop();
            }
        });
    }

    function setEventHandlingForSaveButton() {
        var btn = $('save');
        btn.observe('click', function(event) {

            var changed = $$('.info-changed');
            var params = []

            changed.each(function(elm) {
                var category = null;

                // Make sure we won't save the change more than once
                elm.removeClassName('info-changed');

                var classes = $w(elm.className);

                // Find the class name that denotes an information structure category
                for(var i = 0; i < classes.length; i++) {
                    var klass = classes[i];
                    if(categories.include(klass) || non_spec_categories.include(klass)) {
                        category = klass;
                        break;
                    }
                };

                // Find the antecedent id (if any) or contrast group (if any)
                for(var i = 0; i < classes.length; i++) {
                    var klass = classes[i];
                    if(klass.startsWith('ant-') || klass.startsWith('con-')) {
                        category += ';' + klass;
                    }
                }

                // Extract the numerical part of the element id
                var id = InfoStatus.getTokenId(elm);

                // If this is a prodrop token, add info about the verb it is related to and
                // the kind of relation it has
                if(id.startsWith('new')) {
                    for(var i = 0; i < classes.length; i++) {
                        var klass = classes[i];
                        if(klass.startsWith('prodrop')) {
                            category += ';' + klass;
                            break;
                        }
                    };
                }
                params.push('tokens['+ id + ']=' + category);
            });
            new Ajax.Request(document.location.href.match(url_without_last_part)[0],
                             {
                                 method: 'put',
                                 parameters: params.join('&') +
                                     '&authenticity_token=' + authenticity_token,
                                 onSuccess: function(response) {
                                     // Any new tokens, which have IDs on the form 'token-newX', need to get their
                                     // real ID set now that they have been saved to the database. A mapping from
                                     // "fake" IDs to real IDs will have been returned from the server.
                                     $H(response.responseText.evalJSON()).each(function(pair) {
                                         $('token-' + pair.key).writeAttribute('id', 'token-' + pair.value);
                                     });

                                     var elm = $('server-message');
                                     elm.update('Changes saved');
                                     elm.show();
                                     elm.highlight();
                                     elm.fade({delay: 2.0});
                                 },
                                 onFailure: function(response) {
                                     var elm = $('server-message');
                                     elm.show();
                                     elm.update('Error: ' + response.responseText);
                                     elm.highlight({startcolor: 'ff0000'});
                                     elm.fade({delay: 2.0});
                                 }
                             }
                            );
            event.stop();
        });
    }

    return {

        // public functions

        init: function() {
            if(annotatables != null) return;  // because the script may be included several times on the same page

            this.setAnnotatablesAndUnannotatables();
            setEventHandlingForDocument();
            setEventHandlingForSaveButton();

            this.selectToken(annotatables[0]);
        },

        setAnnotatablesAndUnannotatables: function() {
            // Make sure old event handling is removed before determining the two sets again
            if(annotatables) {
                removeEventHandlingForAnnotatables();
            }
            if(unannotatables) {
                removeEventHandlingForUnannotatables();
            }

            annotatables = $$('span.info-annotatable');
            unannotatables = $$('span.info-unannotatable');

            setEventHandlingForAnnotatables();
            setEventHandlingForUnannotatables();
        },

        selectToken: function(elm) {
            selected_token = elm;
            annotatables.invoke('removeClassName', 'info-selected');
            selected_token.addClassName('info-selected');

            annotatables.each(function(annotatable, i) {
                if(annotatables[i] === selected_token) {
                    selected_token_index = i;
                    throw $break;
                }
            });
            var delete_prodrop_button = $('delete-prodrop-button');
            if(elm.innerHTML.startsWith('PRO-')) {
                delete_prodrop_button.enable();
            }
            else {
                delete_prodrop_button.disable();
            }
            AnaphoraAndContrast.showAntecedentFor(elm);
        },

        getSelectedToken: function() {
            return selected_token;
        },

        // Returns the numerical part of the element id
        getTokenId: function(token) {
            return token.id.slice('token-'.length);
        }
    }
}();

document.observe('dom:loaded', function() {
    InfoStatus.init();
});
