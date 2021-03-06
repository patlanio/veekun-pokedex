# encoding: utf8
"""Defines the resource traversal tree for the site.
"""
from pyramid.i18n import get_locale_name
from pyramid.interfaces import IResourceURL
from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy.sql.expression import func
from zope.interface import Interface, implements

import pokedex.db.tables as t
from veekun_pokedex.model import session


# List of supported site languages and localized URLs.  These are needed at
# import time, which is a bad time to be doing gettext translations.
LANGUAGES = dict(
    en = dict(
        pokemon=u'pokemon',
        moves=u'moves',
        types=u'types',
        abilities=u'abilities',
        items=u'items',
        places=u'places',
        natures=u'natures',
    ),
    ja = dict(
        pokemon=u'ポケモン',
        moves=u'わざ',
        types=u'タイプ',
        abilities=u'abilities',
        items=u'items',
        places=u'へん',
        natures=u'natures',
    ),
)


class LanguageIndex(object):
    def __init__(self, request):
        self.request = request

    def __getitem__(self, key):
        if key not in LANGUAGES:
            raise KeyError

        # TODO could cache these in-process...
        language = session.query(t.Language).filter_by(identifier=key).one()
        session.default_language_id = language.id

        # TODO this leaves a request out to dry if it doesn't happen to come
        # through here
        self.request._LOCALE_ = key
        self.request._veekun_language = language
        return localized_resource_root[key]

class PokedexIndex(object):
    table = None
    parent_class = None

    def __init__(self, parent_row=None):
        self.parent_row = parent_row

    def __getitem__(self, key):
        # `key` should be a whatever name
        q = session.query(self.table) \
            .join(self.table.names_local) \
            .filter(func.lower(self.table.names_table.name) == key)

        if self.parent_row is not None:
            q = q.with_parent(self.parent_row)

        try:
            row = q.one()
        except NoResultFound:
            # TODO ought to do a 404 with lookup
            raise KeyError
        else:
            if self.parent_class:
                return self.parent_class(row)
            else:
                return row

class PokemonIndex(PokedexIndex):
    table = t.PokemonSpecies

class MoveIndex(PokedexIndex):
    table = t.Move

class TypeIndex(PokedexIndex):
    table = t.Type

class AbilityIndex(PokedexIndex):
    table = t.Ability

class ItemIndex(PokedexIndex):
    table = t.Item

class PlaceIndex(PokedexIndex):
    table = t.Location

class RegionIndex(PokedexIndex):
    table = t.Region
    parent_class = PlaceIndex

class NatureIndex(PokedexIndex):
    table = t.Nature


# This is the good stuff, which defines the actual resource tree.  Keys are
# initial path components.
# Here's the simple templated version.
resource_root = dict(
    pokemon = PokemonIndex(),
    moves = MoveIndex(),
    types = TypeIndex(),
    abilities = AbilityIndex(),
    items = ItemIndex(),
    places = RegionIndex(),
    natures = NatureIndex(),
)

# And here's the per-language one.
localized_resource_root = dict()
for locale in LANGUAGES.keys():
    localized_resource_root[locale] = dict()
    for key, value in resource_root.iteritems():
        localized_key = LANGUAGES[locale][key]
        localized_resource_root[locale][localized_key] = value




# Aaaand fix up URL generation

class PokedexURLGenerator(object):
    implements(IResourceURL)

    def __init__(self, resource, request):
        locale = get_locale_name(request)

        if isinstance(resource, PokedexIndex) or (
                isinstance(resource, type) and issubclass(resource, PokedexIndex)):

            resource_type = resource.table
            resource_chain = []
        else:
            resource_type = type(resource)
            resource_chain = [resource]

        # TODO make this use adapters or whatever
        if issubclass(resource_type, t.Pokemon):
            prefix = 'pokemon'
        elif issubclass(resource_type, t.PokemonSpecies):
            prefix = 'pokemon'
        elif issubclass(resource_type, t.Move):
            prefix = 'moves'
        elif issubclass(resource_type, t.Type):
            prefix = 'types'
        elif issubclass(resource_type, t.Item):
            prefix = 'items'
        elif issubclass(resource_type, t.Region):
            prefix = 'places'
        elif issubclass(resource_type, t.Location):
            prefix = 'places'

            if resource_chain:
                resource_chain.insert(0, resource.region)
        elif issubclass(resource_type, t.Ability):
            prefix = 'abilities'
        elif issubclass(resource_type, t.Nature):
            prefix = 'natures'
        else:
            raise TypeError(repr(resource))

        path_parts = [u'', locale, LANGUAGES[locale][prefix]]
        path_parts.extend(res.name.lower() for res in resource_chain)

        self.virtual_path = u'/'.join(path_parts)
        self.physical_path = self.virtual_path
