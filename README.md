<p align="center">
  <a href="https://vezham.com">
      <img width="20%" src="https://static.cdn.vezham.com/images/logo-black.png" alt="vezham" />
      <h1 align="center">Vezham</h1>
  </a>
</p>
</br>

# v0xFE-deployer

See [guidelines](https://storybook.vezham.com/?path=/docs/guidelines-get-started--overview) to get started.


v0xFE-apps-platforms
- academy
- blogs
- help_center
- policy_center
- whats_new

v0xFE-apps-suites
- hq
- one

v0xFE-apps-widgets
- chat_widget

v0xFE-apps-pods
- accounts
- business
- iam

v0xFE-apps-cdns
- static_cdn

v0xFE-apps-internals
- playground
- storybook-sb
- storybook

----

v0xFE-lab

          GCP_PROJECT_ID2=$(echo $OUT | jq -r '.project_id')
          echo "::add-mask::$GCP_PROJECT_ID2"
          echo "GCP_PROJECT_ID2=$GCP_PROJECT_ID2" >> $GITHUB_ENV