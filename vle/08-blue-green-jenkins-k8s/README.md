# VLE 8 – Automated Blue-Green Deployment Strategy using Jenkins, Kubernetes, Docker

Two identical environments (**blue**, **green**) run side by side. `shop-live` Service (NodePort 30081) points at one colour, `shop-preview` (30082) at the other. A release goes to the **idle** colour, is smoke-tested, approved, then traffic flips instantly by patching the Service selector. The old colour stays running → rollback is a one-second selector flip.

**Steps**
1. Setup from `vle/00-jenkins-k8s-setup` (same as VLE 7).
2. Jenkins → New Item `shop-bluegreen` → Pipeline from SCM → Script Path `vle/08-blue-green-jenkins-k8s/Jenkinsfile`.
3. Build #1 → deploys to the idle colour (green, since live starts as blue), so approve it. Then **Build again** so both colours exist.
4. In a terminal run `bash scripts/watch-live.sh` → trigger another build → approve → watch colour change with `fails=0`.
5. Rollback: **Build with Parameters** → `ROLLBACK_ONLY` ✓ (or `bash scripts/switch.sh blue`).

Pages: live http://localhost:30081 (blue = dark blue background, green = dark green), preview http://localhost:30082.

**Blue-green vs rolling (viva):** blue-green = full duplicate env, instant switch & rollback, 2× resources; rolling = gradual pod replacement, cheaper, mixed versions during rollout; canary = small % of traffic first.
