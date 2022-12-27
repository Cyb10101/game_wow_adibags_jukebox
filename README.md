# AdiBags - Jukebox

Addon for World of Warcraft to filter "Jukebox" using AdiBags.

* [CurseForge: AdiBags_Jukebox](https://www.curseforge.com/wow/addons/adibags-jukebox)
* [CurseForge: AdiBags](https://www.curseforge.com/wow/addons/adibags)
* [CurseForge: idTip](https://www.curseforge.com/wow/addons/idTip)

## Development

* [API Clients](https://develop.battle.net/access/clients)
* [API Documentation](https://develop.battle.net/documentation/world-of-warcraft/game-data-apis)

Software:

```bash
sudo apt install curl jq
```

Required API Authorization:

```bash
source functions.sh
authentificate "{Your client id}" "{Your client secret}"
```

### Deploy

* Update `Interface` id in *.toc file

```bash
git add *.toc
git commit
git tag -f 100002.1
git push && git push --tags
```

* Wait until CurseForge build automatically

### Translation

```bash
# Translate: item name (22206, -- Bouquet of Red Roses)
wowItemTranslate 22206 37898 ...

# Translate: Achievement category
wowAchievementCategoryTranslate 155 156 ...
```

### Simple methods

```bash
# Get item
wowItem 22206

# Get achievement categories
wowAchievementCategories
less /tmp/wowAchievementCategories.json
```
