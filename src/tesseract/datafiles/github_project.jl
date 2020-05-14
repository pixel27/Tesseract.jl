# MIT License
#
# Copyright (c) 2020 Joshua E Gentry

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# =========================================================================================
"""
    struct GitHubProject
        owner::String
        package::String
        branch::String
        basedir::String
    end

This structure holds details about a GitHub project we will be downloading information
from.

__Values:__

| Name    | Description
| :------ | :----------
| owner   | The owner of the project.
| package | The package to look in.
| branch  | The branch to use.
| basedir | The directory in the package to look for the files in.
"""
struct GitHubProject
    owner::String
    package::String
    branch::String
    basedir::String
end

# =========================================================================================
"""
    gh_url(
        gh::GitHubProject
    )::String

Build the URL to retrieve the contents of the project form GitHub.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | gh   |         | The project to get the URL for.
"""
function gh_url(
    gh::GitHubProject
        )::String
    local url = "$GITHUB_CONTENTS_BASE/$(gh.owner)/$(gh.package)/contents"

    if isempty(gh.basedir)
        url = string(url, "?ref=$(gh.branch)")
    else
        url = string(url , "/$(gh.basedir)?ref=$(gh.branch)")
    end

    return url
end

# =========================================================================================
"""
    gh_contents(
        gh::GitHubProject
    )::Union{AbstractDict, AbstractArray}

Get the contents of the directory on GitHub.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | gh   |         | The project to get the contents of.

__Exceptions:__

| Name         | Reason
| :----------- | :-----
| NetworkError | There was an issue downloading the JSON object.
"""
function gh_contents(
            gh::GitHubProject
        )::Union{AbstractDict, AbstractArray}
    local url = gh_url(gh)
    return download_json(url)
end
