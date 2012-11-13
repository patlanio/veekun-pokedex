<%inherit file="/_base.mako"/>
<%namespace name="lib" file="/_lib.mako"/>

<%block name="title">${move.name} [Move] - veekun</%block>

## XXX undupe this, if possible
<%block name="subnav">
<nav id="subnav">
    <div class="portrait">
        <div class="eyeball-crop">${'xxx sprite'}</div>
        <div class="name">${move.name}</div>
    </div>
    <ol class="prev-next">
        <li class="prev">
        <a href="ditto">
            <div class="wedge"></div>
            <div class="eyeball-crop"><img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${move.id - 1}.png"></div>
            <div class="name">XXX</div>
        </a>
        </li>
        <li class="next">
        <a href="vaporeon">
            <div class="name">XXX</div>
            <div class="eyeball-crop"><img src="http://veekun.com/dex/media/pokemon/main-sprites/black-white/${move.id + 1}.png"></div>
            <div class="wedge"></div>
        </a>
        </li>
    </ol>
</nav>
<nav id="breadcrumbs">
    <ol>
        <li><a href="/">veekun</a></li>
        <li><a href="/">Pokémon</a></li>
        <li>
            <span class="icon-eyeball-crop"><img src="http://veekun.com/dex/media/pokemon/icons/${move.id}.png"></span>
            ${move.name}
        </li>
        <li>
            ludicrously detailed
            <a href="/">flavor</a> or
            <a href="/">locations</a>
        </li>
    </ol>
</nav>
</%block>

<section>
    <h1>${_(u'Essentials')}</h1>

    
    <div class="columns">
        <section class="col4">
            <h2>${_(u'Overview')}</h2>

            <dl class="horizontal">
                <dt>Name</dt>
                <dd>${move.name}</dd>
                <dt>Introduced in</dt>
                <dd>${lib.generation_icon(move.generation)}</dd>
                <dt>Type</dt>
                <dd>${lib.type_icon(move.type)}</dd>
            </dl>
        </section>

        <div class="col8">
            <section>
                <h2>${_(u'Effect summary')}</h2>
                ## TODO markdown
                ${move.move_effect.prose_local.short_effect}
            </section>
        </div>
    </div>

    <section>
        <h2>${_(u'Type')}</h2>
        <%def name="_type_efficacy_pair(efficacy, efficacy_label, description)">
            <dt>${description} (×${efficacy_label})</dt>
            <dd>
                % if efficacy in efficacy_types:
                <ul class="inline">
                    % for type_ in efficacy_types[efficacy]:
                    <li>${lib.type_icon(type_)}</li>
                    % endfor
                </ul>
                % else:
                <em>${_(u'none')}</em>
                % endif
            </dd>
        </%def>

        <dl class="horizontal">
            ${_type_efficacy_pair(0, u'0', _(u'Ineffective'))}
            ##% if len(pokemon.types) >= 2:
            ##    ${_type_efficacy_pair(25, u'¼', _(u'Very resistant'))}
            ##% endif
            ${_type_efficacy_pair(50, u'½', _(u'Not very effective'))}
            ## Don't show normal damage
            ##${_type_efficacy_pair(100, u'1', _(u'Normal'))}
            ${_type_efficacy_pair(200, u'2', _(u'Super effective'))}
            ##% if len(pokemon.types) >= 2:
            ##    ${_type_efficacy_pair(400, u'4', _(u'Very vulnerable'))}
            ##% endif
        </dl>
    </section>

    <section>
        <h2>${_(u"Machines")}</h2>
        <dl class="horizontal">
        % for machine_row in move.machines:
        ## XXX really need to handle version-group icons better
            <dt>${lib.any_version_icon(machine_row.version_group)}</dt>
            <dd>${machine_row.machine_number}</dd>
        % endfor
        </dl>
    </section>

    <section>
        <h2>${_(u'Numbers')}</h2>

        <dl class="horizontal">
            <dt>${_(u'Power')}</dt>
            <dd>
              % if move.power == 0:
                <em>${_(u'no damage')}</em>
              % elif move.power == 1:
                <em>${_(u'variable')}</em>
              % else:
                ${move.power}
                ## TODO
                ##${_(u"{power}; percentile {perc:.1f}").format(power=c.move.power, perc=c.power_percentile * 100)}
                XXX could use some context, like, how much damage that does.  also, inline damage calculator!
              % endif
            </dd>
            <dt>${_(u'Accuracy')}</dt>
            <dd>
              % if move.accuracy is None:
                <em>${_(u'cannot miss')}</em>
              % else:
                ${move.accuracy}%
                ## TODO this is suck
                ##% if c.move.accuracy != 100 and c.move.damage_class.identifier != 'non-damaging':
                ##${_(u"≈ {0:.1f} power").format(c.move.power * c.move.accuracy / 100.0)}
                ## TODO scope lens..  anything else?  ajax thing with accuracy up/down?
              % endif
            </dd>
            <dt>${_(u'PP')}</dt>
            ## XXX can this be None?
            ## TODO pp-up
            <dd>${move.pp}</dd>
            <dt>${_(u'Target')}</dt>
            <dd>
                ## TODO illustrations
                ## TODO japans.
                ${move.target.identifier}
                ##${move.target.name_map['en']}
                ##${move.target.description_map['en']}
            </dd>
            <dt>${_(u'Effect chance')}</dt>
            <dd>
                ## TODO would be nice if i knew precisely what the effect were here
              % if move.effect_chance:
                ${move.effect_chance}%
              % else:
                ${_(u'n/a')}
              % endif
            </dd>
            <dt>${_(u'Priority')}</dt>
            ## TODO style like in move table; fast/slow
            <dd>${move.priority}</dd>
        </dl>
    </section>
</section>

<section>
    <h1>${_(u'Effect')}</h1>

    <div class="columns">
        <section class="col8">
            ## TODO doesn't exist in ja
            ${move.move_effect.prose_local.effect}
        </section>

        <section class="col4">
            <h2>${_(u"Mechanics")}</h2>
            
            <ul>
            % for flag in move.flags:
                <li>${flag.identifier}</li>
            % endfor
            </ul>

        <% meta = move.meta %>
        % if meta:
            <ul>
                <li>
                    <a href="{url(controller='dex_search', action='move_search', category=meta.category.identifier)}">
                        ${meta.category.description}</a>
                </li>
                % if meta.meta_ailment_id:
                <li>
                    % if meta.ailment_chance:
                    ${meta.ailment_chance}% chance to
                    <a href="{url(controller='dex_search', action='move_search', ailment=meta.ailment.identifier)}">
                        inflict ${meta.ailment.name}</a>
                    % else:
                    <a href="{url(controller='dex_search', action='move_search', ailment=meta.ailment.identifier)}">
                        Inflicts ${meta.ailment.name}</a>
                    % endif
                </li>
                % endif
                % if meta.flinch_chance:
                <li>${meta.flinch_chance}% chance to
                    <a href="{url(controller='dex_search', action='move_search', flinch_chance='>0')}">
                        make the target flinch</a>
                </li>
                % endif
                % if move.meta_stat_changes:
                <li>
                    % if meta.stat_chance:
                    ${meta.stat_chance}% chance to
                    % endif
                    % for stat_change in move.meta_stat_changes:
                    <a href="{url(controller='dex_search', action='move_search', **dict([('stat_change_' + stat_change.stat.identifier.replace('-', '_'), stat_change.change)]))}">
                        ${u'raise' if stat_change.change > 0 else u'lower'} ${stat_change.stat.name}
                        by ${abs(stat_change.change)}</a>
                    % endfor
                </li>
                % endif

                % if meta.crit_rate:
                <li>
                    <a href="{url(controller='dex_search', action='move_search', crit_rate='y')}">
                        Critical hit rate increased by ${meta.crit_rate}</a>
                </li>
                % endif
                % if meta.min_hits:
                <li>
                    <a href="{url(controller='dex_search', action='move_search', multi_hit='y')}">
                        Hits ${meta.min_hits}${u'–{0}'.format(meta.max_hits) if meta.max_hits != meta.min_hits else u''} times</a>
                </li>
                % endif
                % if meta.min_turns:
                <li>
                    ## XXX sometimes this number is bogus; see Toxic, where it's 0x0f
                    <a href="{url(controller='dex_search', action='move_search', multi_turn='y')}">
                        Effect lasts ${meta.min_turns}${u'–{0}'.format(meta.max_turns) if meta.max_turns != meta.min_turns else u''} turns</a>
                </li>
                % endif
                % if meta.recoil and meta.recoil > 0:
                <li>
                    <a href="{url(controller='dex_search', action='move_search', recoil='>0')}">
                        User takes ${meta.recoil}% of the damage inflicted as recoil</a>
                </li>
                % elif meta.recoil and meta.recoil < 0:
                <li>
                    <a href="{url(controller='dex_search', action='move_search', recoil='<0')}">
                        User absorbs ${abs(meta.healing)}% of the damage inflicted</a>
                </li>
                % endif
                % if meta.healing and meta.healing > 0:
                <li>
                    <a href="{url(controller='dex_search', action='move_search', healing='>0')}">
                        User regains ${meta.healing}% of its max HP</a>
                </li>
                % elif meta.healing and meta.healing < 0:
                <li>
                    <a href="{url(controller='dex_search', action='move_search', healing='<0')}">
                        User loses ${abs(meta.healing)}% of its max HP</a>
                </li>
                % endif
            </ul>
        % endif
        </section>
    </div>

    <h2>${_(u'Related moves')}</h2>
    ...
</section>

<section>
    <h1>${_(u'Flavor')}</h1>

    <h2>${_(u'Flavor text')}</h2>
    ## TODO other languages?
    ## XXX whoops this shows every language we've got lol
    <dl class="horizontal">
      % for flavor_text_row in move.flavor_text:
        ## XXX blah blah better vg icons
        <dt>${lib.any_version_icon(flavor_text_row.version_group)}</dt>
        <dd>${flavor_text_row.flavor_text}</dd>
      % endfor
    </dl>

    <h2>${_(u'Names')}</h2>
    ${lib.names_list(move.name_map)}

    XXX internal ids!
</section>

% if move.contest_effect or move.super_contest_effect:
<section>
    <h1>${_(u'Contests')}</h1>

    <div class="columns">

    % if move.contest_effect:
    <div class="col6">
        <h2>${lib.generation_icon_by_id(3)} ${_(u'Contest')}</h2>
        <dl class="horizontal">
            <dt>${_(u"Type")}</dt>
            ##<dd>${h.pokedex.pokedex_img('contest-types/{1}/{0}.png'.format(move.contest_type.identifier, c.game_language.identifier), alt=move.contest_type.name)}</dd>
            <dt>${_(u"Appeal")}</dt>
            <dd title="${move.contest_effect.appeal}">${u'♡' * move.contest_effect.appeal}</dd>
            <dt>${_(u"Jam")}</dt>
            <dd title="${move.contest_effect.jam}">${u'♥' * move.contest_effect.jam}</dd>
            <dt>${_(u"Flavor text")}</dt>
            <dd>${move.contest_effect.flavor_text}</dd>

            <dt>${_(u"Use after")}</dt>
            <dd>
                % if move.contest_combo_prev:
                <ul class="inline-commas">
                    % for combo_move in move.contest_combo_prev:
                    <li><a href="${request.resource_url(combo_move)}">${combo_move.name}</a></li>
                    % endfor
                </ul>
                % else:
                None
                % endif
            </dd>
            <dt>${_("Use before")}</dt>
            <dd>
                % if move.contest_combo_next:
                <ul class="inline-commas">
                    % for combo_move in move.contest_combo_next:
                    <li><a href="${request.resource_url(combo_move)}">${combo_move.name}</a></li>
                    % endfor
                </ul>
                % else:
                None
                % endif
            </dd>
        </dl>
    </div>
    % endif

    % if move.super_contest_effect:
    <div class="col6">
        <h2>${lib.generation_icon_by_id(4)} ${_(u"Super Contest")}</h2>
        <dl class="horizontal">
            <dt>${_("Type")}</dt>
            ##<dd>${h.pokedex.pokedex_img('contest-types/{1}/{0}.png'.format(move.contest_type.identifier, c.game_language.identifier), alt=move.contest_type.name)}</dd>
            <dt>${_("Appeal")}</dt>
            <dd title="${move.super_contest_effect.appeal}">${u'♡' * move.super_contest_effect.appeal}</dd>
            <dt>${_("Flavor text")}</dt>
            <dd>${move.super_contest_effect.flavor_text}</dd>

            <dt>${_("Use after")}</dt>
            <dd>
                % if move.super_contest_combo_prev:
                <ul class="inline-commas">
                    % for combo_move in move.super_contest_combo_prev:
                    <li><a href="${request.resource_url(combo_move)}">${combo_move.name}</a></li>
                    % endfor
                </ul>
                % else:
                None
                % endif
            </dd>
            <dt>${_("Use before")}</dt>
            <dd>
                % if move.super_contest_combo_next:
                <ul class="inline-commas">
                    % for combo_move in move.super_contest_combo_next:
                    <li><a href="${request.resource_url(combo_move)}">${combo_move.name}</a></li>
                    % endfor
                </ul>
                % else:
                None
                % endif
            </dd>
        </dl>
    </div>
    % endif

    </div>
</section>
% endif

<section>
    <h1>${_(u'Pokémon')}</h1>

    ...
</section>

<section>
    <h1>${_(u'External links')}</h1>

    <ul>
      % if move.generation.id <= 1:
        <li>${lib.generation_icon_by_id(1)} <a href="http://www.math.miami.edu/~jam/azure/attacks/${move.name[0].lower()}/${move.name.lower().replace(' ', '_')}.htm">${_("Azure Heights")}</a></li>
      % endif
        <li><a href="http://bulbapedia.bulbagarden.net/wiki/${move.name.replace(' ', '_')}_%28move%29">${_("Bulbapedia")}</a></li>
        <li><a href="http://www.legendarypokemon.net/attacks/${move.name.replace(' ', '+')}/">${_(u"Legendary Pokémon")}</a></li>
        <li><a href="http://www.psypokes.com/dex/techdex/${"%03d" % move.id}">${_("PsyPoke")}</a></li>
        <li><a href="http://www.serebii.net/attackdex-bw/${move.name.lower().replace(' ', '')}.shtml">${_("Serebii.net")}</a></li>
        <li><a href="http://www.smogon.com/bw/moves/${move.name.lower().replace(' ', '_')}">${_("Smogon")}</a></li>
    </ul>
</section>
