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
using HTTP
using JSON

# =================================================================================================
"""
    struct GithubTrainingData
        owner::String
        package::String
        branch::String
        basedir::String
    end

The GithubTrainingData object holds the details about where to find the Tesseract training data in
a GitHub project.

__Values:__

| Name    | Description
| :------ | :----------
| owner   | The owner of the project.
| package | The package to look in.
| branch  | The branch to use.
| basedir | The directory in the package to look for the files in.

__Constructors:__

    GithubTrainingData()

Creates a default instance accessing the standard files found at
https://github.com/tesseract-ocr/tessdata_best.

    GithubTrainingData(
        owner,
        package,
        branch = "master",
        basedir = ""
    )

Creates an instance to pull the files from the specified repository.  Optionally you can can
provide the branch and directory to pull from.
"""
struct GithubTrainingData
    owner::String
    package::String
    branch::String
    basedir::String
    GithubTrainingData() = GithubTrainingData(GITHUB_TRAINING_OWNER, GITHUB_TRAINING_PACKAGE, "master", "")
    GithubTrainingData(owner, package, branch = "master", basedir = "") = new(owner, package, branch, basedir)
end

# =================================================================================================
"""
    gt_url(
        g::GithubTrainingData
    )::String

Create the base URL that can be used to download the training data.  The url always ends with a
"/".

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | g    |         | The GithubTrainingData to create the download URL for.
"""
function gh_url(
            g::GithubTrainingData
        )::String
    if isempty(g.basedir)
        return "$GITHUB_DOWNLOAD_BASE/$(g.owner)/$(g.package)/$(g.branch)/"
    end

    return "$GITHUB_DOWNLOAD_BASE/$(g.owner)/$(g.package)/$(g.branch)/$(g.basedir)/"
end

# =================================================================================================
"""
    gt_contents_url(
        g::GithubTrainingData
    )::String

Create the URL to query github for the contents of the directory containing the trainingdata.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | g    |         | The GithubTrainingData to create the URL for.

__Details:__

This method creates the URL to access the JSON API exposed by GitHub.
"""
function gt_contents_url(
            g::GithubTrainingData
        )::String
    if isempty(g.basedir)
        return "$GITHUB_CONTENTS_BASE/$(g.owner)/$(g.package)/contents?ref=$(g.branch)"
    end

    return "$GITHUB_CONTENTS_BASE/$(g.owner)/$(g.package)/contents/$(g.basedir)?ref=$(g.branch)"
end

# =================================================================================================
"""
    gh_contents(
        g::GithubTrainingData
    )::Dict{String, String}

Query GitHub for the contents of the directory containing the training data and create a mapping of
the training files to their SHA1 value.

__Arguments:__

| T | Name | Default | Description
|:--| :--- | :------ | :----------
| R | g    |         | The GithubTrainingData to get the contents for.

__Exceptions:__

| Name         | Reason
| :----------- | :-----
| NetworkError | There was a network error retrieving the contents from GitHub.

"""
function gh_contents(
            g::GithubTrainingData
        )::Dict{String, String}
    local result   = Dict{String, String}()
    local url      = gt_contents_url(g)
    local response = HTTP.request("GET", url)

    if response.status == 200
        # -----------------------------------------------------------------------------------------
        # Parse the response from the server.
        local data  = String(response.body)
        local files = nothing

        try
            files = JSON.parse(data)
        catch ex
            # -------------------------------------------------------------------------------------
            # Server didn't respond with JSON data.
            if isa(ex, ErrorException)
                @warn "Unexpected response from the server: $data"
                throw(NetworkError(url))
            end
            rethrow(ex)
        end

        # -----------------------------------------------------------------------------------------
        # Server didn't respond with a list of objects.
        if isa(files, AbstractVector) == false
            @warn "Unexpected response from the server: $data"
            throw(NetworkError(url))
        end

        # -----------------------------------------------------------------------------------------
        # Loop through the files on the server.
        for file in files
            local filename = get_json_safe(String, file, "name")
            local sha      = get_json_safe(String, file, "sha")

            # -------------------------------------------------------------------------------------
            # JSON object didn't contain a name and sha.
            if filename == nothing || sha == nothing
                @warn "Unexpected response from the server: $file"
                throw(NetworkError(url))
            end

            # -------------------------------------------------------------------------------------
            # Add the filename/sha to the dictionary.
            if endswith(filename, DATA_FILE_EXT)
                result[filename] = sha
            end
        end

    else
        # -----------------------------------------------------------------------------------------
        # Server returned an error
        @warn "Could not retrieve contents of [$(url)], HTTP status: $(response.status)"
        throw(NetworkError(url))
    end

    return result
end
