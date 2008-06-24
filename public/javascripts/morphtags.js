var morphtag_selection = new ExclusiveSelectionClass('selected', false);

var PaletteWidget = Class.create({
  initialize: function(id, id_guesses) {
    this.widget = $(id);
    this.guesses = $(id_guesses);
  },

  activate: function() { this.widget.show(); },

  deactivate: function() { this.widget.hide(); },

  clearSuggestions: function() { 
    removeAllChildren(this.guesses); 
    this.guesses.insert("<label>Suggestions:</label> ");
  },

  addSuggestion: function(morphtag, lemma, onClick) {
    this.guesses.insert("<input type='button' value='" + 
      this._presentMorphLemmaTag(morphtag, lemma) +
        "' onclick='" + onClick + "'/> ");
  },

  // Generates the presentation form for morph+lemma tag.
  _presentMorphLemmaTag: function(morphtag, lemma) {
    return present_tags(morphtag) + ' (' + lemma + ')';
  },

  showSuggestions: function() { this.guesses.show(); },

  hideSuggestions: function() { this.guesses.hide(); },

  setLemma: function(lemma) {
    $('lemma').value = lemma;
  },

  setMorphtags: function(morphtags) {
    // Update major field options
    var options = $('major_field').options;
    options.length = 0;
    major_values.each(function(e) {
      options[options.length] = new Option(e[1], e[0]);
    });
    $('major_field').show();

    // Do major, minor and mood first
    setSelectedByValue('major_field', morphtags.get('major'));
    $('major_field').show();
    majorSelected();

    setSelectedByValue('minor_field', morphtags.get('minor'));
    minorSelected();
     
    setSelectedByValue('mood_field', morphtags.get('mood'));
    moodSelected();
     
    // Do the rest
    morphtags.each(function(pair) {
      if (pair.key != 'major' && pair.key != 'minor' && pair.key != 'mood' && pair.key != 'extra')
      setSelectedByValue(pair.key + '_field', pair.value);
    });
  }
});

var palette = new PaletteWidget('palette', 'guesses');

function onTokenSelect(token_id)
{
  morphtag_selection.onSelection($('item-' + token_id), onActivate, onDeactivate);
}

// Updates the activated token with guess values.
function onGuessClick(morphtags, lemma) {
  palette.setMorphtags($H(morphtags));
  palette.setLemma(lemma);

  onPaletteChange();
}

// Updates the guess/tag palette for the activated token.
function onActivate(element)
{
  palette.activate();

  var id = element.identify();
  id = id.sub('item-', '');

  // Handle precomputed guesses, if any
  var suggestions = $F('suggestions-' + id).evalJSON();

  if (suggestions) {
    palette.clearSuggestions();

    suggestions.each(function(suggestion) {
      var suggestion_data = suggestion[0];
      var suggestion_confidence = suggestion[1];
      var morphtag_suggestion = $H(suggestion_data[0]);
      var lemma_suggestion = suggestion_data[1];
      if (suggestion_data[2]) {
        // Add variant number
        lemma_suggestion += '#' + suggestion_data[2];
      }
      palette.addSuggestion(morphtag_suggestion, lemma_suggestion,
        "onGuessClick(" + morphtag_suggestion.toJSON() + ", \"" + lemma_suggestion + "\")");
    });

    palette.showSuggestions();
  } else
    palette.hideSuggestions();

  // Set the information from the activated token.
  var current_fields = $F('morphtag-' + id).evalJSON();
  var current_lemma = $F('lemma-' + id);

  palette.setMorphtags($H(current_fields));
  palette.setLemma(current_lemma);
}

function onDeactivate(element)
{
  palette.deactivate();
}

function onPaletteChange()
{
  var tags = new Hash();

  morphtag_fields.each(function(t) {
    tags.set(t, getSelectSelection($(t + '_field')));
  });

  var element = morphtag_selection.getSelection();
  var id = element.identify();
  id = id.sub('item-', '');
  $('morphtag-' + id).value = tags.toJSON();
  $('lemma-' + id).value = $F('lemma');

  onUpdateTokenPresentation(element);
}

// Updates the presentation fields for a token.
function onUpdateTokenPresentation(element) {
  var id = element.identify().sub('item-', '');
  var current_morphtags = $H($F('morphtag-' + id).evalJSON());
  var current_lemma = $F('lemma-' + id);

  // Update human readable display
  var pos = element.down('.pos');
  pos.innerHTML = present_pos_tags(current_morphtags); 

  var morphology = element.down('.morphology');
  morphology.innerHTML = present_morphology_tags(current_morphtags); 

  var lemma = element.down('.lemma');
  lemma.innerHTML = current_lemma ? '(' + current_lemma + ')' : '&nbsp;';

  // Finally, remove any non-good "quality" tags, as we should be good
  // by now.
  element.down('.morph-lemma-tags').removeClassName('mguessed');
  element.down('.morph-lemma-tags').removeClassName('munannotated');
  element.down('.morph-lemma-tags').addClassName('mannotated');
}

document.observe('dom:loaded', function() {
  morphtag_fields.each(function(field) {  
    $(field + '_field').observe('change', onPaletteChange);
  });

  //$('lemma').observe('keypressed', function() { alert("foo"); onPaletteChange(); });

  palette.deactivate();
});
